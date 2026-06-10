import '../models/sim_order.dart';

class OrderService {
  OrderService._() {
    // Add mock orders for user-customer
    _orders.addAll([
      SimOrder(
        id: 'ORD-1001',
        userId: 'user-customer',
        simId: 'sim-002',
        receiverName: 'Nguyễn Văn Khách',
        receiverPhone: '0909000000',
        address: 'Thành phố Hồ Chí Minh',
        totalPrice: 28500000,
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        note: 'Giao hàng giờ hành chính',
      ),
      SimOrder(
        id: 'ORD-1002',
        userId: 'user-customer',
        simId: 'sim-004',
        receiverName: 'Nguyễn Văn Khách',
        receiverPhone: '0909000000',
        address: 'Hà Nội',
        totalPrice: 9600000,
        status: OrderStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  static final OrderService instance = OrderService._();

  final List<SimOrder> _orders = [];

  List<SimOrder> getAllOrders() {
    return List.unmodifiable(_orders);
  }

  List<SimOrder> getOrdersByUserId(String userId) {
    return _orders.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void createOrder(SimOrder order) {
    _orders.add(order);
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
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
  }

  void cancelOrder(String orderId) {
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
  }
}
