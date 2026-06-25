enum SimStatus { available, reserved, sold }

extension SimStatusLabel on SimStatus {
  String get label {
    return switch (this) {
      SimStatus.available => 'Con hang',
      SimStatus.reserved => 'Cho thanh toan',
      SimStatus.sold => 'Da ban',
    };
  }
}

extension SimStatusApiName on SimStatus {
  String get backendName {
    return switch (this) {
      SimStatus.available => 'Available',
      SimStatus.reserved => 'Reserved',
      SimStatus.sold => 'Sold',
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

  factory BeautifulSim.fromJson(Map<String, Object?> json) {
    final statusName = json['status'] as String? ?? 'available';

    return BeautifulSim(
      id: json['id'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      carrier: json['carrier'] as String? ?? '',
      type: json['type'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toInt(),
      meaning: json['meaning'] as String? ?? '',
      status: SimStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == statusName.toLowerCase(),
        orElse: () => SimStatus.available,
      ),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'carrier': carrier,
      'type': type,
      'price': price,
      'meaning': meaning,
      'status': status.backendName,
      'description': description,
    };
  }
}
