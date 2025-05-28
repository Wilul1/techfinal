import 'package:flutter/foundation.dart';
import '../models/shipping_address.dart';

class ShippingProvider with ChangeNotifier {
  List<ShippingAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ShippingAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  ShippingAddress? get defaultAddress => 
      _addresses.isNotEmpty ? _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.first,
      ) : null;

  // Load addresses
  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _addresses = [
        ShippingAddress(
          id: '1',
          fullName: 'John Doe',
          phoneNumber: '+1 (555) 123-4567',
          addressLine1: '123 Main Street',
          addressLine2: 'Apt 4B',
          city: 'New York',
          state: 'NY',
          postalCode: '10001',
          country: 'United States',
          type: 'Home',
          isDefault: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ShippingAddress(
          id: '2',
          fullName: 'John Doe',
          phoneNumber: '+1 (555) 123-4567',
          addressLine1: '456 Corporate Blvd',
          addressLine2: 'Suite 100',
          city: 'New York',
          state: 'NY',
          postalCode: '10002',
          country: 'United States',
          type: 'Work',
          isDefault: false,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add address
  Future<void> addAddress(ShippingAddress address) async {
    try {
      // If this is set as default, remove default from others
      if (address.isDefault) {
        _addresses = _addresses.map((addr) => 
          addr.copyWith(isDefault: false)).toList();
      }
      
      _addresses.add(address);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Update address
  Future<void> updateAddress(ShippingAddress updatedAddress) async {
    try {
      final index = _addresses.indexWhere((addr) => addr.id == updatedAddress.id);
      if (index != -1) {
        // If this is set as default, remove default from others
        if (updatedAddress.isDefault) {
          _addresses = _addresses.map((addr) => 
            addr.id != updatedAddress.id ? addr.copyWith(isDefault: false) : addr).toList();
        }
        
        _addresses[index] = updatedAddress;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      _addresses.removeWhere((addr) => addr.id == addressId);
      
      // If we deleted the default address and there are still addresses,
      // make the first one default
      if (_addresses.isNotEmpty && !_addresses.any((addr) => addr.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      _addresses = _addresses.map((addr) => 
        addr.copyWith(isDefault: addr.id == addressId)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }
}