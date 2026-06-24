import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_order.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/sim_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  var _didPrefill = false;
  var _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrefill) {
      return;
    }
    final user = AuthService.instance.currentUser;
    _nameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phone ?? '';
    _didPrefill = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  BeautifulSim? _resolveSim() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final simId = switch (arguments) {
      BeautifulSim sim => sim.id,
      String id => id,
      _ => null,
    };
    if (simId == null) {
      return null;
    }
    for (final sim in SimService.instance.getAllSims()) {
      if (sim.id == simId) {
        return sim;
      }
    }
    return null;
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final requiredError = _requiredValidator(value, 'số điện thoại');
    if (requiredError != null) {
      return requiredError;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^0\d{9}$').hasMatch(digits)) {
      return 'Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0.';
    }
    return null;
  }

  Future<void> _submit(BeautifulSim sim) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước khi đặt mua.')),
      );
      Navigator.of(context).pushNamed(AppRoutes.auth);
      return;
    }

    final latestSim = SimService.instance
        .getAllSims()
        .where((item) => item.id == sim.id)
        .firstOrNull;
    if (latestSim == null || latestSim.status != SimStatus.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SIM này vừa được đặt mua. Vui lòng chọn SIM khác.'),
        ),
      );
      setState(() {});
      return;
    }

    setState(() => _isSubmitting = true);
    
    final now = DateTime.now();
    final order = SimOrder(
      id: 'ORD-${now.millisecondsSinceEpoch}',
      userId: user.id,
      simId: latestSim.id,
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
      address: _addressController.text.trim(),
      totalPrice: latestSim.price,
      status: OrderStatus.pending,
      createdAt: now,
      note: _noteController.text.trim(),
    );

    try {
      await OrderService.instance.createOrder(order);
      await SimService.instance.loadSims(); // reload sims to reflect sold status
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppPalette.teal, size: 48),
          title: const Text('Đặt mua thành công'),
          content: Text(
            'Đơn ${order.id} đã được tạo. Nhân viên sẽ liên hệ xác nhận trong thời gian sớm nhất.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              key: const ValueKey('view_orders_button'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Xem đơn hàng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể đặt mua SIM: $e')),
      );
      return;
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.myOrders);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sim = _resolveSim();
    if (sim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đặt mua SIM')),
        body: const _MissingCheckoutSim(),
      );
    }

    final isAvailable = sim.status == SimStatus.available;
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt mua SIM')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _OrderSummary(sim: sim),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin nhận hàng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPalette.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vui lòng nhập chính xác để nhân viên liên hệ xác nhận.',
                      style: TextStyle(color: AppPalette.muted),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('receiver_name_field'),
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Họ tên người nhận',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          _requiredValidator(value, 'họ tên người nhận'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('receiver_phone_field'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('address_field'),
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ nhận hàng',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      validator: (value) =>
                          _requiredValidator(value, 'địa chỉ nhận hàng'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('note_field'),
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (không bắt buộc)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppPalette.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: AppPalette.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thanh toán khi nhận hàng',
                            style: TextStyle(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Không cần chuyển khoản trước. Bạn thanh toán sau khi nhận và kiểm tra SIM.',
                            style: TextStyle(
                              color: AppPalette.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const ValueKey('confirm_order_button'),
              onPressed: isAvailable && !_isSubmitting
                  ? () => _submit(sim)
                  : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                !isAvailable
                    ? 'SIM đã được bán'
                    : _isSubmitting
                    ? 'Đang tạo đơn...'
                    : 'Xác nhận đặt mua',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bằng việc xác nhận, bạn đồng ý để nhân viên liên hệ về đơn hàng này.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.sim});

  final BeautifulSim sim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.red, AppPalette.redDark],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sim_card, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sim.phoneNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sim.carrier} • ${sim.type}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(sim.price),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingCheckoutSim extends StatelessWidget {
  const _MissingCheckoutSim();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 58,
              color: AppPalette.muted,
            ),
            const SizedBox(height: 14),
            const Text(
              'Bạn chưa chọn SIM để đặt mua.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.simList),
              child: const Text('Chọn SIM'),
            ),
          ],
        ),
      ),
    );
  }
}
