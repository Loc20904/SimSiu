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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'carrier': carrier,
      'type': type,
      'price': price,
      'meaning': meaning,
      'status': status.name == 'available' ? 'Available' : 'Sold',
      'description': description,
    };
  }

  factory BeautifulSim.fromJson(Map<String, Object?> json) {
    final statusStr = (json['status'] as String? ?? 'Available').toLowerCase();
    return BeautifulSim(
      id: json['id'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      carrier: json['carrier'] as String? ?? '',
      type: json['type'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toInt(),
      meaning: json['meaning'] as String? ?? '',
      status: statusStr == 'available' ? SimStatus.available : SimStatus.sold,
      description: json['description'] as String? ?? '',
    );
  }
}
