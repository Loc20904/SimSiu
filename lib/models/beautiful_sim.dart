enum SimStatus { available, sold }

extension SimStatusLabel on SimStatus {
  String get label {
    return switch (this) {
      SimStatus.available => 'Còn hàng',
      SimStatus.sold => 'Đã bán',
    };
  }
}

class BeautifulSim {
  const BeautifulSim({
    required this.id,
    required this.phoneNumber,
    required this.carrier,
    required this.type,
    required this.price,
    required this.meaning,
    required this.status,
    required this.description,
  });

  final String id;
  final String phoneNumber;
  final String carrier;
  final String type;
  final int price;
  final String meaning;
  final SimStatus status;
  final String description;
}
