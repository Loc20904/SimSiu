// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_order.dart';
import '../../services/order_service.dart';
import '../../services/sim_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  BeautifulSim? _findSim(String simId) {
    try {
      return SimService.instance
          .getAllSims()
          .firstWhere((s) => s.id == simId);
    } catch (_) {
      return null;
    }
  }

  Color _getOrderStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppPalette.gold,
      OrderStatus.confirmed => AppPalette.blue,
      OrderStatus.completed => AppPalette.teal,
      OrderStatus.cancelled => AppPalette.danger,
    };
  }

  void _showAddEditSimDialog([BeautifulSim? sim]) {
    final isEdit = sim != null;
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: sim?.phoneNumber ?? '');
    final priceController = TextEditingController(text: sim?.price.toString() ?? '');
    final meaningController = TextEditingController(text: sim?.meaning ?? '');
    final descController = TextEditingController(text: sim?.description ?? '');

    String selectedCarrier = sim?.carrier ?? 'Viettel';
    String selectedType = sim?.type ?? 'Sim tam hoa';
    SimStatus selectedStatus = sim?.status ?? SimStatus.available;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Sửa thông tin SIM' : 'Thêm SIM mới'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          hintText: 'VD: 0909 888 888',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          final cleaned = v.replaceAll(' ', '');
                          final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(cleaned);
                          if (!isDigitsOnly) {
                            return 'Số điện thoại chỉ được chứa chữ số và khoảng trắng';
                          }
                          if (cleaned.length < 9 || cleaned.length > 11) {
                            return 'Số điện thoại phải từ 9 đến 11 chữ số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCarrier,
                        decoration: const InputDecoration(labelText: 'Nhà mạng'),
                        items: ['Viettel', 'Mobifone', 'Vinaphone', 'Vietnamobile', 'Wintel']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedCarrier = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: 'Loại SIM'),
                        items: [
                          'Sim tam hoa',
                          'Sim tứ quý',
                          'Sim lục quý',
                          'Sim lộc phát',
                          'Sim thần tài',
                          'Sim năm sinh',
                          'Khác'
                        ]
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedType = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá bán (đ)',
                          hintText: 'VD: 125000000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập giá bán';
                          }
                          final raw = v.replaceAll('.', '').replaceAll(' ', '');
                          final parsed = int.tryParse(raw);
                          if (parsed == null) {
                            return 'Giá bán phải là số nguyên hợp lệ';
                          }
                          if (parsed <= 0) {
                            return 'Giá bán phải lớn hơn 0đ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: meaningController,
                        decoration: const InputDecoration(
                          labelText: 'Ý nghĩa số',
                        ),
                        maxLines: 2,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập ý nghĩa của SIM';
                          }
                          if (v.trim().length < 5) {
                            return 'Ý nghĩa SIM phải chứa ít nhất 5 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả chi tiết',
                        ),
                        maxLines: 2,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập mô tả chi tiết';
                          }
                          if (v.trim().length < 10) {
                            return 'Mô tả chi tiết phải chứa ít nhất 10 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SimStatus>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Trạng thái'),
                        items: SimStatus.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedStatus = v);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final rawPrice = int.parse(
                        priceController.text.replaceAll('.', '').replaceAll(' ', ''),
                      );

                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        if (isEdit) {
                          final updated = BeautifulSim(
                            id: sim.id,
                            phoneNumber: phoneController.text.trim(),
                            carrier: selectedCarrier,
                            type: selectedType,
                            price: rawPrice,
                            meaning: meaningController.text.trim(),
                            status: selectedStatus,
                            description: descController.text.trim(),
                          );
                          await SimService.instance.updateSim(updated);
                        } else {
                          final newSim = BeautifulSim(
                            id: 'sim-${DateTime.now().millisecondsSinceEpoch}',
                            phoneNumber: phoneController.text.trim(),
                            carrier: selectedCarrier,
                            type: selectedType,
                            price: rawPrice,
                            meaning: meaningController.text.trim(),
                            status: selectedStatus,
                            description: descController.text.trim(),
                          );
                          await SimService.instance.addSim(newSim);
                        }

                        if (!mounted) return;
                        navigator.pop(); // Đóng loading
                        navigator.pop(); // Đóng dialog Add/Edit

                        setState(() {});
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Đã cập nhật thông tin SIM thành công.'
                                  : 'Đã thêm SIM mới thành công.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        navigator.pop(); // Đóng loading
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Thao tác thất bại: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteSim(BeautifulSim sim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa SIM'),
        content: Text('Bạn có chắc chắn muốn xóa SIM số ${sim.phoneNumber} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await SimService.instance.deleteSim(sim.id);
        
        if (!mounted) return;
        navigator.pop(); // Đóng loading

        setState(() {});
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đã xóa SIM số ${sim.phoneNumber} khỏi hệ thống.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        navigator.pop(); // Đóng loading
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Không thể xóa SIM: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
 // feat/booking_history
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý hệ thống'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sim_card), text: 'Quản lý SIM'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Đơn đặt hàng'),
            ],
            indicatorColor: AppPalette.teal,
            labelColor: AppPalette.teal,
            unselectedLabelColor: AppPalette.muted,
          ),
        ),
        body: TabBarView(
          children: [
            _buildSimsTab(),
            _buildOrdersTab(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddEditSimDialog(),
              backgroundColor: AppPalette.teal,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Thêm SIM'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimsTab() {
    final sims = SimService.instance.getAllSims();

    if (sims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sim_card_outlined,
              size: 64,
              color: AppPalette.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có SIM nào trong kho',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80), // extra padding for FAB
      itemCount: sims.length,
      itemBuilder: (context, index) {
        final sim = sims[index];
        final isAvailable = sim.status == SimStatus.available;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isAvailable ? AppPalette.teal : AppPalette.muted)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.sim_card,
                  color: isAvailable ? AppPalette.teal : AppPalette.muted,
                ),
              ),
              title: Text(
                sim.phoneNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${sim.carrier} • ${sim.type}'),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(sim.price),
                    style: const TextStyle(
                      color: AppPalette.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: (isAvailable ? AppPalette.teal : AppPalette.muted)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sim.status.label,
                      style: TextStyle(
                        color: isAvailable ? AppPalette.teal : AppPalette.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppPalette.blue, size: 20),
                    onPressed: () => _showAddEditSimDialog(sim),
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppPalette.danger, size: 20),
                    onPressed: () => _confirmDeleteSim(sim),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    final orders = OrderService.instance.getAllOrders();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppPalette.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đơn đặt hàng nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getOrderStatusColor(order.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getOrderStatusColor(order.status).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          order.status.label,
                          style: TextStyle(
                            color: _getOrderStatusColor(order.status),
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
                      const Icon(Icons.sim_card, color: AppPalette.teal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sim?.phoneNumber ?? 'ID SIM: ${order.simId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        formatCurrency(order.totalPrice),
                        style: const TextStyle(
                          color: AppPalette.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 10, thickness: 0.4),
                  const SizedBox(height: 6),
                  _buildDetailItem(Icons.person, 'Người nhận: ${order.receiverName}'),
                  const SizedBox(height: 4),
                  _buildDetailItem(Icons.phone, 'Số điện thoại: ${order.receiverPhone}'),
                  const SizedBox(height: 4),
                  _buildDetailItem(Icons.place, 'Địa chỉ giao: ${order.address}'),
                  if (order.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDetailItem(Icons.edit_note, 'Ghi chú: ${order.note}'),
                  ],
                  const SizedBox(height: 4),
                  _buildDetailItem(Icons.calendar_month, 'Ngày đặt hàng: $formattedDate'),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cập nhật trạng thái:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.muted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.10),
                          ),
                          color: Colors.white,
                        ),
                        child: DropdownButton<OrderStatus>(
                          value: order.status,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: AppPalette.teal),
                          style: const TextStyle(
                            color: AppPalette.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          items: OrderStatus.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            );
                          }).toList(),
                           onChanged: (newStatus) async {
                            if (newStatus != null) {
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                await OrderService.instance.updateOrderStatus(order.id, newStatus);
                                await SimService.instance.loadSims();
                                await OrderService.instance.loadOrders();

                                if (!mounted) return;
                                navigator.pop(); // Đóng loading

                                setState(() {});
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã cập nhật trạng thái đơn hàng ${order.id} thành "${newStatus.label}".',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                navigator.pop(); // Đóng loading
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Không thể cập nhật trạng thái đơn hàng: $e'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
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
