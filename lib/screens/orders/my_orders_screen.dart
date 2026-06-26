import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_order.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../../services/sim_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _firstLoad = true;
  List<PendingPayOsPayment> _pendingPayments = [];
  Timer? _countdownTimer;
  var _isRefreshingData = false;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _pendingPayments.isNotEmpty) {
        final hasExpired = _pendingPayments.any(
          (payment) => !payment.expiredAt.isAfter(DateTime.now()),
        );
        if (hasExpired && !_isRefreshingData) {
          _refreshData();
          return;
        }

        setState(() {});
      }
    });
    _refreshData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_isRefreshingData) {
      return;
    }

    _isRefreshingData = true;
    try {
      final results = await Future.wait([
        SimService.instance.fetchSims(force: true),
        OrderService.instance.loadOrders(),
        PaymentService.instance.fetchPendingPayOsPayments(),
      ]);
      _pendingPayments = results[2] as List<PendingPayOsPayment>;
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _firstLoad = false;
        });
      }
      _isRefreshingData = false;
    }
  }

  BeautifulSim? _findSim(String simId) {
    try {
      return SimService.instance.getAllSims().firstWhere((s) => s.id == simId);
    } catch (_) {
      return null;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppPalette.gold,
      OrderStatus.pendingPayment => AppPalette.gold,
      OrderStatus.paid => AppPalette.teal,
      OrderStatus.confirmed => AppPalette.blue,
      OrderStatus.completed => AppPalette.teal,
      OrderStatus.paymentExpired => AppPalette.danger,
      OrderStatus.cancelled => AppPalette.danger,
    };
  }

  String _formatRemaining(PendingPayOsPayment payment) {
    final remaining = payment.expiredAt.difference(DateTime.now());
    final seconds = remaining.inSeconds > 0 ? remaining.inSeconds : 0;
    final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
  }

  Future<void> _continuePayment(PendingPayOsPayment payment) async {
    final opened = await launchUrl(
      Uri.parse(payment.checkoutUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong mo duoc trang thanh toan payOS.')),
      );
    }
  }

  Future<void> _confirmCancelPayment(PendingPayOsPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xac nhan huy thanh toan'),
        content: Text('Ban co chac chan muon huy thanh toan ${payment.payOsOrderCode} khong?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Khong'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
            child: const Text('Huy thanh toan'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await PaymentService.instance.cancelPayOsPayment(payment.payOsOrderCode);
      await _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da huy thanh toan, SIM da ve kho.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _confirmCancelOrder(SimOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng ${order.id} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      OrderService.instance.cancelOrder(order.id).then((_) {
        if (mounted) {
          setState(() {});
        }
      });
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi yêu cầu hủy đơn hàng ${order.id}.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // feat/booking_history
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem đơn hàng.')),
      );
    }

    if (_firstLoad) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn hàng của tôi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final orders = OrderService.instance.getOrdersByUserId(user.id);
    final hasItems = orders.isNotEmpty || _pendingPayments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: !hasItems
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppPalette.muted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bạn chưa có đơn hàng nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppPalette.ink.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _pendingPayments.length + orders.length,
                itemBuilder: (context, index) {
                  if (index < _pendingPayments.length) {
                    return _buildPendingPaymentCard(_pendingPayments[index]);
                  }

                  final order = orders[index - _pendingPayments.length];
                  final sim = _findSim(order.simId);
                  final formattedDate =
                      '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppPalette.ink,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      order.status,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _getStatusColor(
                                        order.status,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    order.status.label,
                                    style: TextStyle(
                                      color: _getStatusColor(order.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 0.6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppPalette.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.sim_card,
                                    color: AppPalette.teal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sim?.phoneNumber ?? 'SĐT: ${order.simId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppPalette.ink,
                                        ),
                                      ),
                                      if (sim != null)
                                        Text(
                                          '${sim.carrier} • ${sim.type}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppPalette.muted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatCurrency(order.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppPalette.teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 10, thickness: 0.4),
                            const SizedBox(height: 6),
                            _buildDetailRow(
                              Icons.person_outline,
                              'Người nhận: ${order.receiverName} (${order.receiverPhone})',
                            ),
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              Icons.place_outlined,
                              'Địa chỉ: ${order.address}',
                            ),
                            if (order.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _buildDetailRow(
                                Icons.edit_note_outlined,
                                'Ghi chú: ${order.note}',
                              ),
                            ],
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              Icons.access_time,
                              'Thời gian đặt: $formattedDate',
                            ),
                            if (order.status == OrderStatus.pending || order.status == OrderStatus.pendingPayment) ...[
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: () => _confirmCancelOrder(order),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppPalette.danger,
                                    side: const BorderSide(
                                      color: AppPalette.danger,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text('Hủy đơn hàng'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppPalette.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppPalette.muted,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingPaymentCard(PendingPayOsPayment payment) {
    final sim = _findSim(payment.simId);
    final formattedDate =
        '${payment.createdAt.day.toString().padLeft(2, '0')}/${payment.createdAt.month.toString().padLeft(2, '0')}/${payment.createdAt.year} ${payment.createdAt.hour.toString().padLeft(2, '0')}:${payment.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'PAYOS-${payment.payOsOrderCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppPalette.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppPalette.gold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Cho thanh toan',
                      style: TextStyle(
                        color: AppPalette.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPalette.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.pending_actions_outlined,
                      color: AppPalette.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sim?.phoneNumber ?? 'SDT: ${payment.simId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppPalette.ink,
                          ),
                        ),
                        if (sim != null)
                          Text(
                            '${sim.carrier} - ${sim.type}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(payment.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppPalette.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 10, thickness: 0.4),
              const SizedBox(height: 6),
              _buildDetailRow(
                Icons.timer_outlined,
                'Con lai: ${_formatRemaining(payment)}',
              ),
              const SizedBox(height: 4),
              _buildDetailRow(
                Icons.person_outline,
                'Nguoi nhan: ${payment.receiverName} (${payment.receiverPhone})',
              ),
              const SizedBox(height: 4),
              _buildDetailRow(
                Icons.place_outlined,
                'Dia chi: ${payment.address}',
              ),
              if (payment.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildDetailRow(Icons.edit_note_outlined, 'Ghi chu: ${payment.note}'),
              ],
              const SizedBox(height: 4),
              _buildDetailRow(Icons.access_time, 'Thoi gian tao: $formattedDate'),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _confirmCancelPayment(payment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.danger,
                      side: const BorderSide(color: AppPalette.danger),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Huy'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: payment.checkoutUrl.isEmpty
                        ? null
                        : () => _continuePayment(payment),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Thanh toan tiep'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

