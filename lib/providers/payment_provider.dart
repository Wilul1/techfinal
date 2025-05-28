import 'package:flutter/material.dart';
import '../models/payment_method.dart';

class PaymentProvider with ChangeNotifier {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  PaymentMethod? get defaultPaymentMethod => 
      _paymentMethods.isNotEmpty ? _paymentMethods.firstWhere(
        (method) => method.isDefault,
        orElse: () => _paymentMethods.first,
      ) : null;

  // Load payment methods
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _paymentMethods = [
        PaymentMethod(
          id: '1',
          type: PaymentMethodType.creditCard,
          cardNumber: '**** **** **** 1234',
          cardHolderName: 'John Doe',
          expiryDate: '12/25',
          isDefault: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        PaymentMethod(
          id: '2',
          type: PaymentMethodType.creditCard,
          cardNumber: '**** **** **** 5678',
          cardHolderName: 'John Doe',
          expiryDate: '06/26',
          isDefault: false,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
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

  // Add payment method
  Future<void> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      if (paymentMethod.isDefault) {
        _paymentMethods = _paymentMethods.map((method) => 
          method.copyWith(isDefault: false)).toList();
      }
      
      _paymentMethods.add(paymentMethod);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Update payment method
  Future<void> updatePaymentMethod(PaymentMethod updatedMethod) async {
    try {
      final index = _paymentMethods.indexWhere((method) => method.id == updatedMethod.id);
      if (index != -1) {
        if (updatedMethod.isDefault) {
          _paymentMethods = _paymentMethods.map((method) => 
            method.id != updatedMethod.id ? method.copyWith(isDefault: false) : method).toList();
        }
        
        _paymentMethods[index] = updatedMethod;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  // Delete payment method
  Future<void> deletePaymentMethod(String methodId) async {
    try {
      _paymentMethods.removeWhere((method) => method.id == methodId);
      
      if (_paymentMethods.isNotEmpty && !_paymentMethods.any((method) => method.isDefault)) {
        _paymentMethods[0] = _paymentMethods[0].copyWith(isDefault: true);
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      _paymentMethods = _paymentMethods.map((method) => 
        method.copyWith(isDefault: method.id == methodId)).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }
}