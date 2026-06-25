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
}
