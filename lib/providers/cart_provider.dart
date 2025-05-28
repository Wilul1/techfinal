import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  List<CartItem> get cartItems => _items; // ✅ Add cartItems getter for UI consistency
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty; // ✅ Add isEmpty getter
  String? get error => _error;
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  
  double get total {
    return _items.fold(0.0, (total, item) => total + (item.product.price * item.quantity));
  }

  // ✅ Add totalPrice getter for UI consistency
  double get totalPrice => total;

  double get subtotal => total;

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      _error = null;
      
      final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);
      
      if (existingItemIndex >= 0) {
        // Update existing item quantity
        _items[existingItemIndex] = _items[existingItemIndex].copyWith(
          quantity: _items[existingItemIndex].quantity + quantity,
        );
      } else {
        // Add new item
        _items.add(CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
        ));
      }
      
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _error = 'Failed to add item to cart: $e';
      notifyListeners();
    }
  }

  // Remove product from cart
  Future<void> removeFromCart(String itemId) async { // ✅ Fixed: use itemId instead of productId
    try {
      _error = null;
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _error = 'Failed to remove item from cart: $e';
      notifyListeners();
    }
  }

  // Remove product by product ID
  Future<void> removeProductFromCart(String productId) async {
    try {
      _error = null;
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _error = 'Failed to remove product from cart: $e';
      notifyListeners();
    }
  }

  // Update item quantity by item ID
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    try {
      _error = null;
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        _items[itemIndex] = _items[itemIndex].copyWith(quantity: newQuantity);
        notifyListeners();
        await _saveToStorage();
      }
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
    }
  }

  // Update product quantity by product ID
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeProductFromCart(productId);
      return;
    }

    try {
      _error = null;
      final itemIndex = _items.indexWhere((item) => item.product.id == productId);
      if (itemIndex >= 0) {
        _items[itemIndex] = _items[itemIndex].copyWith(quantity: newQuantity);
        notifyListeners();
        await _saveToStorage();
      }
    } catch (e) {
      _error = 'Failed to update product quantity: $e';
      notifyListeners();
    }
  }

  // Increase item quantity
  Future<void> increaseQuantity(String productId) async {
    final item = getCartItem(productId);
    if (item != null) {
      await updateQuantity(item.id, item.quantity + 1);
    }
  }

  // Decrease item quantity
  Future<void> decreaseQuantity(String productId) async {
    final item = getCartItem(productId);
    if (item != null) {
      await updateQuantity(item.id, item.quantity - 1);
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _error = null;
      _items.clear();
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }

  // Load cart from storage
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('user_cart_items');
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items = decoded.map((item) {
          try {
            return CartItem.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing cart item: $e');
            return null;
          }
        }).where((item) => item != null).cast<CartItem>().toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load cart: $e';
      notifyListeners();
      print('Error loading cart: $e');
    }
  }

  // Save cart to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('user_cart_items', cartJson);
    } catch (e) {
      print('Error saving cart: $e');
      _error = 'Failed to save cart: $e';
    }
  }

  // Get total quantity for a specific product
  int getProductQuantity(String productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  // Calculate total with tax
  double getTotalWithTax({double taxRate = 0.085}) {
    return total * (1 + taxRate);
  }

  // Calculate shipping cost
  double getShippingCost() {
    return total >= 100 ? 0.0 : 9.99;
  }

  // Get final total (subtotal + tax + shipping)
  double getFinalTotal({double taxRate = 0.085}) {
    final subtotal = total;
    final tax = subtotal * taxRate;
    final shipping = getShippingCost();
    return subtotal + tax + shipping;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get cart summary
  Map<String, dynamic> getCartSummary({double taxRate = 0.085}) {
    final subtotal = total;
    final tax = subtotal * taxRate;
    final shipping = getShippingCost();
    final finalTotal = subtotal + tax + shipping;

    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': finalTotal,
    };
  }

  // Validate cart (check stock, prices, etc.)
  Future<bool> validateCart() async {
    try {
      // Here you would typically check with your backend
      // For now, we'll just validate that all items are still available
      final validItems = _items.where((item) => 
          item.product.isAvailable && 
          item.quantity <= (item.product.stockQuantity ?? 999)
      ).toList();

      if (validItems.length != _items.length) {
        _items = validItems;
        notifyListeners();
        await _saveToStorage();
        return false; // Cart was modified
      }

      return true; // Cart is valid
    } catch (e) {
      _error = 'Failed to validate cart: $e';
      notifyListeners();
      return false;
    }
  }
}