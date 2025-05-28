import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get featured products
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') return _products;
    return _products.where((p) => 
      p.category?.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (product.category?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Load products from Firestore
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Listen to product stream
      _productService.getAllProducts().listen(
        (products) {
          _products = products;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product
  Future<void> addProduct(Product product) async {
    try {
      await _productService.addProduct(product);
      // Products will be updated automatically through the stream
    } catch (e) {
      _error = 'Failed to add product: $e';
      notifyListeners();
    }
  }

  // Update product
  Future<void> updateProduct(Product updatedProduct) async {
    try {
      await _productService.updateProduct(updatedProduct.id, updatedProduct);
      // Products will be updated automatically through the stream
    } catch (e) {
      _error = 'Failed to update product: $e';
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      // Products will be updated automatically through the stream
    } catch (e) {
      _error = 'Failed to delete product: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}