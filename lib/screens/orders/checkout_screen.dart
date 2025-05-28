import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shipping_address.dart';
import '../../models/payment_method.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shipping_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../shipping-address/shipping_address_screen.dart';
import '../payment/payment_methods_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ShippingAddress? _selectedAddress;
  PaymentMethod? _selectedPaymentMethod;
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  double _discount = 0.0;
  String? _promoCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultSelections();
    });
  }

  void _loadDefaultSelections() {
    final shippingProvider = Provider.of<ShippingProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    setState(() {
      _selectedAddress = shippingProvider.defaultAddress;
      _selectedPaymentMethod = paymentProvider.defaultPaymentMethod;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Checkout Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  const SizedBox(height: 20),
                  
                  // Shipping Address
                  _buildShippingSection(),
                  const SizedBox(height: 20),
                  
                  // Payment Method
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                  
                  // Promo Code
                  _buildPromoCodeSection(),
                  const SizedBox(height: 20),
                  
                  // Order Notes
                  _buildOrderNotesSection(),
                  const SizedBox(height: 20),
                  
                  // Price Breakdown
                  _buildPriceBreakdown(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildCheckoutButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          _buildProgressStep(1, 'Cart', true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'Checkout', true),
          _buildProgressLine(false),
          _buildProgressStep(3, 'Payment', false),
          _buildProgressLine(false),
          _buildProgressStep(4, 'Confirm', false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.card,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.black : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Order Summary', style: AppTextStyles.heading3),
                  const Spacer(),
                  Text(
                    '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'item' : 'items'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...cartProvider.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.card,
                          child: const Icon(Icons.image, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShippingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedAddress != null 
              ? AppColors.green.withOpacity(0.3)
              : AppColors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _selectedAddress != null ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 8),
              const Text('Shipping Address', style: AppTextStyles.heading3),
              const Spacer(),
              TextButton(
                onPressed: () => _selectShippingAddress(),
                child: Text(
                  _selectedAddress != null ? 'Change' : 'Select',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAddress != null) ...[
            Text(
              _selectedAddress!.fullName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedAddress!.fullAddress,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _selectedAddress!.phoneNumber,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Please select a shipping address',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedPaymentMethod != null 
              ? AppColors.green.withOpacity(0.3)
              : AppColors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: _selectedPaymentMethod != null ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 8),
              const Text('Payment Method', style: AppTextStyles.heading3),
              const Spacer(),
              TextButton(
                onPressed: () => _selectPaymentMethod(),
                child: Text(
                  _selectedPaymentMethod != null ? 'Change' : 'Select',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedPaymentMethod != null) ...[
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedPaymentMethod!.cardBrand,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedPaymentMethod!.maskedNumber,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPaymentMethod!.cardHolderName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Please select a payment method',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Promo Code', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _applyPromoCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Promo code applied! You saved \$${_discount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.green),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Order Notes', style: AppTextStyles.heading3),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Optional',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add special instructions for your order...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.total;
        final shipping = subtotal >= 100 ? 0.0 : 9.99;
        final tax = subtotal * 0.085;
        final total = subtotal + shipping + tax - _discount;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price Details', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _buildPriceRow('Subtotal', subtotal),
              _buildPriceRow('Shipping', shipping, 
                  note: subtotal >= 100 ? 'Free shipping on orders over \$100' : null),
              _buildPriceRow('Tax', tax),
              if (_discount > 0)
                _buildPriceRow('Discount', -_discount, isDiscount: true),
              const Divider(height: 20),
              _buildPriceRow('Total', total, isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false, String? note}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isTotal 
                  ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyMedium,
            ),
            Text(
              '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
              style: isTotal 
                  ? AppTextStyles.price.copyWith(fontSize: 18)
                  : isDiscount
                      ? AppTextStyles.bodyMedium.copyWith(color: AppColors.green)
                      : AppTextStyles.bodyMedium,
            ),
          ],
        ),
        if (note != null) ...[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              note,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final canCheckout = _selectedAddress != null && 
                           _selectedPaymentMethod != null && 
                           cartProvider.items.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckout && !_isProcessing ? _processOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock),
                          const SizedBox(width: 8),
                          Text(
                            'Place Order • \$${_calculateTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  double _calculateTotal() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cartProvider.total;
    final shipping = subtotal >= 100 ? 0.0 : 9.99;
    final tax = subtotal * 0.085;
    return subtotal + shipping + tax - _discount;
  }

  void _selectShippingAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShippingAddressScreen(isOrderFlow: true),
      ),
    );
    
    if (result != null && result is ShippingAddress) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  void _selectPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodsScreen(isOrderFlow: true),
      ),
    );
    
    if (result != null && result is PaymentMethod) {
      setState(() {
        _selectedPaymentMethod = result;
      });
    }
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cartProvider.total;
    double discount = 0.0;

    switch (code.toUpperCase()) {
      case 'SAVE10':
        discount = subtotal * 0.10;
        break;
      case 'SAVE20':
        discount = subtotal * 0.20;
        break;
      case 'WELCOME':
        discount = 15.0;
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid promo code'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
    }

    setState(() {
      _discount = discount;
      _promoCode = code;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code applied! You saved \$${discount.toStringAsFixed(2)}'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> _processOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final order = await orderProvider.createOrder(
        userId: authProvider.user?.id ?? 'guest',
        cartItems: cartProvider.items,
        shippingAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod!,
        promoCode: _promoCode,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      // Clear cart after successful order
      await cartProvider.clearCart();

      // Navigate to confirmation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process order: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
