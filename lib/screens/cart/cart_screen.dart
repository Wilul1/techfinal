import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../orders/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String couponCode = "";
  double shipping = 20.0;

  double get grandTotal {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return cartProvider.totalPrice + shipping;
  }

  void applyCoupon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon "$couponCode" applied! (Demo only)'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Shopping Cart', style: AppTextStyles.appBarTitle),
            backgroundColor: AppColors.surface,
            iconTheme: const IconThemeData(color: AppColors.primary),
            elevation: 0,
          ),
          body: cartProvider.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    // Cart Items List - Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildCartHeader(cartProvider),
                            const SizedBox(height: 16),
                            _buildCartItemsList(cartProvider),
                          ],
                        ),
                      ),
                    ),
                    // Fixed Order Summary at Bottom
                    _buildOrderSummary(cartProvider),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          const Text(
            'Add some amazing products to get started',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeader(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shopping Cart', style: AppTextStyles.heading3),
              const SizedBox(height: 4),
              Text(
                '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'Item' : 'Items'}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _showClearCartDialog(cartProvider),
            icon: const Icon(Icons.clear_all, color: AppColors.red, size: 18),
            label: const Text('Clear All', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider) {
    return Column(
      children: cartProvider.cartItems.map((cartItem) => 
        _buildCartItem(cartItem, cartProvider)
      ).toList(),
    );
  }

  Widget _buildCartItem(cartItem, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.product.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.product.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${cartItem.product.price.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              decoration: cartItem.quantity > 1 ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (cartItem.quantity > 1) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.price.copyWith(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price and Remove Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _removeItem(cartProvider, cartItem),
                      icon: const Icon(Icons.close, color: AppColors.red, size: 20),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    if (cartItem.quantity == 1)
                      Text(
                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(fontSize: 16),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Quantity Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity:', style: AppTextStyles.bodySmall),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: cartItem.quantity > 1
                            ? () => cartProvider.updateQuantity(cartItem.id, cartItem.quantity - 1)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '${cartItem.quantity}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => cartProvider.updateQuantity(cartItem.id, cartItem.quantity + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // ✅ Don't add top padding, only bottom
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // ✅ Reduced bottom padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Keep this to minimize height
            children: [
              // Coupon Section - Made more compact
              Container(
                height: 40, // ✅ Fixed height for input
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.text, fontSize: 14), // ✅ Smaller text
                        decoration: InputDecoration(
                          hintText: 'Promo code',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // ✅ Reduced padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          isDense: true, // ✅ Makes input more compact
                        ),
                        onChanged: (val) => couponCode = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40, // ✅ Match input height
                      child: ElevatedButton(
                        onPressed: applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12), // ✅ Reduced padding
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Apply', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12), // ✅ Reduced spacing
              
              // Order Summary Details - Made more compact
              Column(
                children: [
                  _buildSummaryRow('Subtotal', '\$${cartProvider.totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 6), // ✅ Reduced spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping', style: TextStyle(color: AppColors.text, fontSize: 14)), // ✅ Smaller text
                      Container(
                        height: 30, // ✅ Fixed height for dropdown
                        child: DropdownButton<double>(
                          value: shipping,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.primary, fontSize: 14),
                          underline: Container(),
                          isDense: true, // ✅ Compact dropdown
                          items: const [
                            DropdownMenuItem(
                              value: 20.0,
                              child: Text('Standard (\$20)', style: TextStyle(fontSize: 14)),
                            ),
                            DropdownMenuItem(
                              value: 50.0,
                              child: Text('Express (\$50)', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => shipping = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // ✅ Reduced spacing
                  const Divider(color: AppColors.card, height: 16), // ✅ Reduced divider height
                  _buildSummaryRow(
                    'Total',
                    '\$${grandTotal.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
              
              const SizedBox(height: 12), // ✅ Reduced spacing
              
              // Checkout Button - Made more compact
              SizedBox(
                width: double.infinity,
                height: 48, // ✅ Fixed height for button
                child: ElevatedButton(
                  onPressed: cartProvider.isEmpty ? null : () => _navigateToCheckout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // ✅ Slightly smaller text
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  child: Text('CHECKOUT (${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'ITEM' : 'ITEMS'})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Update the _buildSummaryRow method for consistency:
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.text,
            fontSize: isTotal ? 16 : 14, // ✅ Smaller font sizes
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.primary : AppColors.text,
            fontSize: isTotal ? 16 : 14, // ✅ Smaller font sizes
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _removeItem(CartProvider cartProvider, cartItem) async {
    await cartProvider.removeFromCart(cartItem.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.product.name} removed from cart'),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showClearCartDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cart', style: AppTextStyles.heading3),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await cartProvider.clearCart();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared successfully'),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }
}