enum OrderStatus {
  pending,
  pendingPayment,
  paid,
  confirmed,
  completed,
  paymentExpired,
  cancelled,
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    return switch (this) {
      OrderStatus.pending => 'Cho xu ly',
      OrderStatus.pendingPayment => 'Cho thanh toan',
      OrderStatus.paid => 'Da thanh toan',
      OrderStatus.confirmed => 'Da xac nhan',
      OrderStatus.completed => 'Hoan tat',
      OrderStatus.paymentExpired => 'Het han thanh toan',
      OrderStatus.cancelled => 'Da huy',
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

  factory SimOrder.fromJson(Map<String, Object?> json) {
    final statusName = json['status'] as String? ?? 'pending';

    return SimOrder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      simId: json['simId'] as String,
      receiverName: json['receiverName'] as String,
      receiverPhone: json['receiverPhone'] as String,
      address: json['address'] as String,
      totalPrice: json['totalPrice'] as int,
      status: OrderStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == statusName.toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String? ?? '',
    );
  }
}
