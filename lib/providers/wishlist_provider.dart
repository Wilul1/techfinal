import 'package:flutter/material.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = false;

  // Getters
  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  // Add to wishlist
  Future<void> addToWishlist(Product product) async {
    if (!isInWishlist(product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  // Remove from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  // Clear wishlist
  Future<void> clearWishlist() async {
    _items.clear();
    notifyListeners();
  }

  // Load wishlist (mock data)
  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock wishlist data - replace with actual API call
      _items = [
        // Add sample products here or load from storage
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to load wishlist: $e');
    }
  }
}