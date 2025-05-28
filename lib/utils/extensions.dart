import '../models/shipping_address.dart';

extension ShippingAddressExtensions on ShippingAddress {
  // ✅ Add label getter without modifying the model
  String get label {
    // Create a smart label based on address characteristics
    if (addressLine1.toLowerCase().contains('work') || 
        addressLine1.toLowerCase().contains('office') ||
        addressLine1.toLowerCase().contains('business')) {
      return 'Work';
    } else if (addressLine1.toLowerCase().contains('home') || 
               addressLine1.toLowerCase().contains('residence')) {
      return 'Home';
    } else {
      // Use city as label if no pattern matches
      return city.isNotEmpty ? city : 'Address';
    }
  }
  
  // ✅ Alternative display name
  String get displayLabel => '$fullName - $city';
  
  // ✅ Short address label
  String get shortLabel => '${addressLine1.split(' ').take(2).join(' ')}, $city';
}