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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userId': userId,
      'simId': simId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'address': address,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory SimOrder.fromJson(Map<String, Object?> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final createdAtStr = json['createdAt'] as String;
    return SimOrder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      simId: json['simId'] as String,
      receiverName: json['receiverName'] as String,
      receiverPhone: json['receiverPhone'] as String,
      address: json['address'] as String,
      totalPrice: json['totalPrice'] as int,
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(createdAtStr).toLocal(),
      note: json['note'] as String? ?? '',
    );
  }
}
