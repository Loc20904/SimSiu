// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_order.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/sim_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
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
      OrderStatus.confirmed => AppPalette.blue,
      OrderStatus.completed => AppPalette.teal,
      OrderStatus.cancelled => AppPalette.danger,
    };
  }

  Future<void> _confirmCancelOrder(SimOrder order) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
      if (!context.mounted) return;
      // Hiển thị vòng chờ loading
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await OrderService.instance.cancelOrder(order.id);
        await SimService.instance.loadSims(); // Làm mới trạng thái sim ở các màn hình khác
        
        if (!mounted) return;
        navigator.pop(); // Đóng vòng chờ loading

        setState(() {});
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đã hủy đơn hàng ${order.id} thành công.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        navigator.pop(); // Đóng vòng chờ loading
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Không thể hủy đơn hàng: $e'),
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

    final orders = OrderService.instance.getOrdersByUserId(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: orders.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
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
                          if (order.status == OrderStatus.pending) ...[
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
}
