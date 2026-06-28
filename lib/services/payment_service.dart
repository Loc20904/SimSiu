import 'api_client.dart';

class PayOsCheckout {
  const PayOsCheckout({
    required this.orderId,
    required this.payOsOrderCode,
    required this.paymentLinkId,
    required this.checkoutUrl,
    required this.qrCode,
  });

  final String orderId;
  final int payOsOrderCode;
  final String paymentLinkId;
  final String checkoutUrl;
  final String qrCode;

  factory PayOsCheckout.fromJson(Map<String, Object?> json) {
    return PayOsCheckout(
      orderId: json['orderId'] as String,
      payOsOrderCode: json['payOsOrderCode'] as int,
      paymentLinkId: json['paymentLinkId'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      qrCode: json['qrCode'] as String? ?? '',
    );
  }
}

class PendingPayOsPayment {
  const PendingPayOsPayment({
    required this.id,
    required this.userId,
    required this.simId,
    required this.payOsOrderCode,
    required this.paymentLinkId,
    required this.checkoutUrl,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.note,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.expiredAt,
    required this.remainingSeconds,
  });

  final String id;
  final String userId;
  final String simId;
  final int payOsOrderCode;
  final String paymentLinkId;
  final String checkoutUrl;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final String note;
  final int amount;
  final String status;
  final DateTime createdAt;
  final DateTime expiredAt;
  final int remainingSeconds;

  factory PendingPayOsPayment.fromJson(Map<String, Object?> json) {
    final remainingSeconds = (json['remainingSeconds'] as num? ?? 0).toInt();
    final parsedExpiredAt = DateTime.tryParse(json['expiredAt'] as String? ?? '')?.toLocal() ??
        DateTime.now();

    return PendingPayOsPayment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      simId: json['simId'] as String? ?? '',
      payOsOrderCode: (json['payOsOrderCode'] as num? ?? 0).toInt(),
      paymentLinkId: json['paymentLinkId'] as String? ?? '',
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      note: json['note'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toInt(),
      status: json['status'] as String? ?? 'Pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      expiredAt: remainingSeconds > 0
          ? DateTime.now().add(Duration(seconds: remainingSeconds))
          : parsedExpiredAt,
      remainingSeconds: remainingSeconds,
    );
  }
}

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  Future<PayOsCheckout> createPayOsOrder({
    required String simId,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required String note,
  }) async {
    final response = await ApiClient.instance.post(
      '/payments/payos/orders',
      body: {
        'simId': simId,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'address': address,
        'note': note,
      },
    );

    return PayOsCheckout.fromJson(response);
  }

  Future<void> cancelPayOsPayment(int orderCode) async {
    await ApiClient.instance.post(
      '/payments/payos/$orderCode/cancel',
      body: <String, Object?>{},
      requiresAuth: true,
    );
  }

  Future<void> syncPayOsPayment(int orderCode) async {
    await ApiClient.instance.post(
      '/payments/payos/$orderCode/sync',
      body: <String, Object?>{},
      requiresAuth: true,
    );
  }

  Future<void> syncPendingPayOsPayments() async {
    await ApiClient.instance.post(
      '/payments/payos/sync-pending',
      body: <String, Object?>{},
      requiresAuth: true,
    );
  }

  Future<List<PendingPayOsPayment>> fetchPendingPayOsPayments() async {
    final response = await ApiClient.instance.getList('/payments/payos/pending');
    return response
        .map((item) => PendingPayOsPayment.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
  }
}
