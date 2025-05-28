import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/shipping_address.dart';
import '../models/payment_method.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  Order? _currentOrder;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Order? get currentOrder => _currentOrder;

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get recent orders (last 30 days)
  List<Order> get recentOrders {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _orders.where((order) => order.createdAt.isAfter(thirtyDaysAgo)).toList();
  }

  // Load orders
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('user_orders');
      
      if (ordersJson != null) {
        final List<dynamic> decoded = jsonDecode(ordersJson);
        _orders = decoded.map((item) => Order.fromJson(item)).toList();
        // Sort by creation date (newest first)
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create order from cart
  Future<Order> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required ShippingAddress shippingAddress,
    required PaymentMethod paymentMethod,
    String? promoCode,
    String? notes,
  }) async {
    try {
      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) => OrderItem(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productImage: cartItem.product.imageUrl,
        price: cartItem.product.price,
        quantity: cartItem.quantity,
      )).toList();

      // Calculate totals
      final subtotal = orderItems.fold<double>(0.0, (sum, item) => sum + item.total);
      final shippingCost = _calculateShippingCost(subtotal, shippingAddress);
      final tax = _calculateTax(subtotal);
      final discount = _calculateDiscount(subtotal, promoCode);
      final total = subtotal + shippingCost + tax - discount;

      // Create order
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        items: orderItems,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        discount: discount,
        total: total,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
        notes: notes,
      );

      // Add to orders list
      _orders.insert(0, order);
      _currentOrder = order;
      
      // Save to storage
      await _saveToStorage();
      
      // Simulate payment processing
      await _processPayment(order);
      
      notifyListeners();
      return order;
      
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        
        // Add tracking number when shipped
        if (newStatus == OrderStatus.shipped) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            trackingNumber: 'TH${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          );
        }
        
        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final order = _orders[orderIndex];
        if (order.canCancel) {
          _orders[orderIndex] = order.copyWith(
            status: OrderStatus.cancelled,
            updatedAt: DateTime.now(),
            notes: order.notes != null ? '${order.notes}\nCancelled: $reason' : 'Cancelled: $reason',
          );
          
          await _saveToStorage();
          notifyListeners();
        } else {
          throw Exception('Order cannot be cancelled at this stage');
        }
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  double _calculateShippingCost(double subtotal, ShippingAddress address) {
    // Free shipping for orders over $100
    if (subtotal >= 100) return 0.0;
    
    // Base shipping cost
    return 9.99;
  }

  double _calculateTax(double subtotal) {
    // 8.5% tax rate
    return subtotal * 0.085;
  }

  double _calculateDiscount(double subtotal, String? promoCode) {
    if (promoCode == null) return 0.0;
    
    switch (promoCode.toUpperCase()) {
      case 'SAVE10':
        return subtotal * 0.10;
      case 'SAVE20':
        return subtotal * 0.20;
      case 'WELCOME':
        return 15.0;
      default:
        return 0.0;
    }
  }

  Future<void> _processPayment(Order order) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Update order status to confirmed
    final orderIndex = _orders.indexWhere((o) => o.id == order.id);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: OrderStatus.confirmed,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(_orders.map((order) => order.toJson()).toList());
      await prefs.setString('user_orders', ordersJson);
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  // Clear all orders (for testing)
  Future<void> clearOrders() async {
    _orders.clear();
    await _saveToStorage();
    notifyListeners();
  }
}