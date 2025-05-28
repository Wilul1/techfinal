enum PaymentMethodType {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String? cvv;
  final String? billingAddress;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    this.cvv,
    this.billingAddress,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // Get display name for payment method type
  String get typeName {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  // Get card brand from card number
  String get cardBrand {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'American Express';
    return 'Card';
  }

  // Get masked card number
  String get maskedNumber {
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  // Check if card is expired
  bool get isExpired {
    try {
      final parts = expiryDate.split('/');
      if (parts.length != 2) return false;
      
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');
      final expiry = DateTime(year, month + 1, 0);
      
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false;
    }
  }

  // Copy with method
  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    String? billingAddress,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      billingAddress: billingAddress ?? this.billingAddress,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'billingAddress': billingAddress,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentMethodType.creditCard,
      ),
      cardNumber: json['cardNumber'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cvv: json['cvv'],
      billingAddress: json['billingAddress'],
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: $typeName, card: $maskedNumber)';
  }
}