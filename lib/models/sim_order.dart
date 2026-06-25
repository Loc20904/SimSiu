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
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      simId: json['simId'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num? ?? 0).toInt(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == statusName.toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      note: json['note'] as String? ?? '',
    );
  }

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
}
