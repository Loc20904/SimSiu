import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/sim_order.dart';
import 'auth_service.dart';
import 'sim_service.dart';

class OrderService {
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

  void clearOrders() {
    _orders.clear();
  }

  Future<void> loadOrders({String? userId}) => fetchOrders(userId: userId);

  Future<void> fetchOrders({String? userId}) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final String url;
      if (user.isAdmin) {
        url = '${ApiConfig.baseUrl}/orders';
      } else {
        final idToFetch = userId ?? user.id;
        url = '${ApiConfig.baseUrl}/orders/user/$idToFetch';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: AuthService.instance.authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders.clear();
        _orders.addAll(data.map((item) => SimOrder.fromJson(item)));
      } else {
        debugPrint('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> createOrder(SimOrder order) async {
    // Optimistic local update
    _orders.add(order);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: AuthService.instance.authHeaders,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        final created = SimOrder.fromJson(jsonDecode(response.body));
        
        // Update local item with server values (like ID or createdAt if server modified them)
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = created;
        }
        
        // Refresh SIMs from backend to reflect the sold status
        await SimService.instance.fetchSims();
      } else {
        debugPrint('Failed to create order on server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating order on server: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId,  OrderStatus status) async {
    // Optimistic local update
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      _orders[index] = SimOrder(
        id: old.id,
        userId: old.userId,
        simId: old.simId,
        receiverName: old.receiverName,
        receiverPhone: old.receiverPhone,
        address: old.address,
        totalPrice: old.totalPrice,
        status: status,
        createdAt: old.createdAt,
        note: old.note,
      );
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status'),
        headers: AuthService.instance.authHeaders,
        body: jsonEncode({'status': status.name}),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Refresh SIM list in case SIM status changed
        await SimService.instance.fetchSims();
      } else {
        debugPrint('Failed to update order status on server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating order status on server: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    // Optimistic local update
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.pending) {
      final old = _orders[index];
      _orders[index] = SimOrder(
        id: old.id,
        userId: old.userId,
        simId: old.simId,
        receiverName: old.receiverName,
        receiverPhone: old.receiverPhone,
        address: old.address,
        totalPrice: old.totalPrice,
        status: OrderStatus.cancelled,
        createdAt: old.createdAt,
        note: old.note,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/cancel'),
        headers: AuthService.instance.authHeaders,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Refresh SIM list in case SIM status was restored
        await SimService.instance.fetchSims();
      } else {
        debugPrint('Failed to cancel order on server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error cancelling order on server: $e');
    }
  }
}
