class ShippingAddress {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String type;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShippingAddress({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.type = 'Home',
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ Add the missing fullAddress getter
  String get fullAddress {
    String address = addressLine1;
    if (addressLine2?.isNotEmpty == true) {
      address += ', $addressLine2';
    }
    address += '\n$city, $state $postalCode';
    address += '\n$country';
    return address;
  }

  // ✅ Add other useful getters
  String get formattedAddress {
    String address = addressLine1;
    if (addressLine2?.isNotEmpty == true) {
      address += ', $addressLine2';
    }
    address += '\n$city, $state $postalCode';
    address += '\n$country';
    return address;
  }

  String get shortAddress {
    return '$addressLine1, $city, $state';
  }

  String get oneLineAddress {
    String address = addressLine1;
    if (addressLine2?.isNotEmpty == true) {
      address += ', $addressLine2';
    }
    address += ', $city, $state $postalCode, $country';
    return address;
  }

  String get displayName {
    return '$fullName ($type)';
  }

  String get cityStateZip {
    return '$city, $state $postalCode';
  }

  // Copy with method
  ShippingAddress copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'type': type,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From JSON
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      type: json['type'] ?? 'Home',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShippingAddress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ShippingAddress(id: $id, fullName: $fullName, city: $city)';
  }
}