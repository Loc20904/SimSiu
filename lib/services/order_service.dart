import 'package:flutter/foundation.dart';

import '../models/sim_order.dart';
import 'api_client.dart';
import 'auth_service.dart';

class OrderService extends ChangeNotifier {
  OrderService._();

  static final OrderService instance = OrderService._();

  final List<SimOrder> _orders = [];

  List<SimOrder> getAllOrders() {
    return List.unmodifiable(_orders);
  }

  List<SimOrder> getOrdersByUserId(String userId) {
    return _orders.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> loadOrders() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _orders.clear();
        notifyListeners();
        return;
      }

      final String path = user.isAdmin ? '/orders' : '/orders/user/${user.id}';
      final List<dynamic> jsonList = await ApiClient.instance.get(path);

      _orders.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          _orders.add(SimOrder.fromJson(Map<String, Object?>.from(item)));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      rethrow;
    }
  }

  Future<void> createOrder(SimOrder order) async {
    try {
      await ApiClient.instance.post('/orders', order.toJson());
      await loadOrders();
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final statusStr = status.name == 'pending'
          ? 'Pending'
          : status.name == 'confirmed'
              ? 'Confirmed'
              : status.name == 'completed'
                  ? 'Completed'
                  : 'Cancelled';

      await ApiClient.instance.put('/orders/$orderId/status', {
        'status': statusStr,
      });
      await loadOrders();
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await ApiClient.instance.post('/orders/$orderId/cancel', null);
      await loadOrders();
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }
}
