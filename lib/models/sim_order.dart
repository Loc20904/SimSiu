enum OrderStatus { pending, confirmed, completed, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label {
    return switch (this) {
      OrderStatus.pending => 'Chờ xử lý',
      OrderStatus.confirmed => 'Đã xác nhận',
      OrderStatus.completed => 'Hoàn tất',
      OrderStatus.cancelled => 'Đã hủy',
    };
  }
}

class SimOrder {
  const SimOrder({
    required this.id,
    required this.userId,
    required this.simId,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final String userId;
  final String simId;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final int totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final String note;
}
