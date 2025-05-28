import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'cart_items';

  static Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> cartData = jsonDecode(cartJson);
      // Note: You'll need to fetch products separately to create CartItem objects
      // This is a simplified version
      return [];
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getCartItemsAsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cartJson));
    }
    return [];
  }

  static Future<void> addToCart(Product product, {int quantity = 1, String? size, String? color}) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await getCartItemsAsMap();
    
    final existingIndex = cartItems.indexWhere((item) => 
        item['productId'] == product.id && 
        item['selectedSize'] == size && 
        item['selectedColor'] == color);
    
    if (existingIndex != -1) {
      cartItems[existingIndex]['quantity'] = 
          (cartItems[existingIndex]['quantity'] ?? 1) + quantity;
    } else {
      cartItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'productId': product.id,
        'productName': product.name,
        'productPrice': product.price,
        'productImage': product.imageUrl,
        'quantity': quantity,
        'selectedSize': size,
        'selectedColor': color,
      });
    }
    
    await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  static Future<void> updateQuantity(String itemId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = await getCartItemsAsMap();
    
    final index = cartItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      if (quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index]['quantity'] = quantity;
      }
      await prefs.setString(_cartKey, jsonEncode(cartItems));
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    await updateQuantity(itemId, 0);
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  static Future<double> getTotalPrice() async {
    final cartItems = await getCartItemsAsMap();
    double total = 0.0;
    for (final item in cartItems) {
      total += (item['productPrice'] ?? 0.0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  static Future<int> getCartItemCount() async {
    final cartItems = await getCartItemsAsMap();
    int count = 0;
    for (final item in cartItems) {
      count += (item['quantity'] ?? 1) as int;
    }
    return count;
  }
}