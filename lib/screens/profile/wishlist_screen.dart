import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../products/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = false;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('user_wishlist');
      
      if (wishlistJson != null) {
        setState(() {
          _wishlistItems = List<Map<String, dynamic>>.from(jsonDecode(wishlistJson));
        });
      } else {
        // Demo wishlist items
        setState(() {
          _wishlistItems = [
            {
              'id': 'PROD001',
              'name': 'iPhone 15 Pro Max',
              'brand': 'Apple',
              'price': 1199.99,
              'originalPrice': 1299.99,
              'discount': 7.7,
              'imageUrl': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800',
              'category': 'Smartphones',
              'rating': 4.8,
              'reviews': 2543,
              'inStock': true,
              'addedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
            },
            {
              'id': 'PROD002',
              'name': 'MacBook Pro 16" M3',
              'brand': 'Apple',
              'price': 2499.99,
              'originalPrice': 2699.99,
              'discount': 7.4,
              'imageUrl': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800',
              'category': 'Laptops',
              'rating': 4.9,
              'reviews': 1876,
              'inStock': true,
              'addedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            },
            {
              'id': 'PROD003',
              'name': 'Sony WH-1000XM5',
              'brand': 'Sony',
              'price': 349.99,
              'originalPrice': 399.99,
              'discount': 12.5,
              'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
              'category': 'Audio',
              'rating': 4.7,
              'reviews': 3421,
              'inStock': false,
              'addedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            },
            {
              'id': 'PROD004',
              'name': 'iPad Pro 12.9" M2',
              'brand': 'Apple',
              'price': 1099.99,
              'originalPrice': 1199.99,
              'discount': 8.3,
              'imageUrl': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800',
              'category': 'Tablets',
              'rating': 4.8,
              'reviews': 987,
              'inStock': true,
              'addedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
          ];
        });
        await _saveWishlist();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load wishlist: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_wishlist', jsonEncode(_wishlistItems));
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Wishlist (${_wishlistItems.length})',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          if (_wishlistItems.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                switch (value) {
                  case 'clear_all':
                    _showClearAllDialog();
                    break;
                  case 'add_all_to_cart':
                    _addAllToCart();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_all_to_cart',
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Add All to Cart'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: AppColors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _wishlistItems.isEmpty
              ? _buildEmptyWishlist()
              : RefreshIndicator(
                  onRefresh: _loadWishlist,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_outline,
            size: 120,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your wishlist is empty',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add products you love to your wishlist',
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: _wishlistItems.length,
        itemBuilder: (context, index) => _buildGridItem(index),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) => _buildListItem(index),
    );
  }

  Widget _buildGridItem(int index) {
    final item = _wishlistItems[index];
    
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToProduct(item['id']),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.card,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),
                  
                  // Remove from wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFromWishlist(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
                  
                  // Discount badge
                  if (item['discount'] != null && item['discount'] > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${item['discount'].toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Stock status
                  if (!item['inStock'])
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Out of Stock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['brand'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    
                    // Price
                    if (item['discount'] != null && item['discount'] > 0) ...[
                      Row(
                        children: [
                          Text(
                            '\$${item['originalPrice'].toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '\$${item['price'].toStringAsFixed(2)}',
                              style: AppTextStyles.price.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '\$${item['price'].toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(fontSize: 14),
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Add to cart button
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: item['inStock']
                                ? () => _addToCart(item)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item['inStock']
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              item['inStock'] ? 'Add to Cart' : 'Out of Stock',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    final item = _wishlistItems[index];
    
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToProduct(item['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.card,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  
                  // Discount badge
                  if (item['discount'] != null && item['discount'] > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '-${item['discount'].toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['brand'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${item['rating']} (${item['reviews']})',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and status
                    Row(
                      children: [
                        if (item['discount'] != null && item['discount'] > 0) ...[
                          Text(
                            '\$${item['originalPrice'].toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: AppTextStyles.price,
                          ),
                        ] else ...[
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: AppTextStyles.price,
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['inStock']
                                ? AppColors.green.withOpacity(0.2)
                                : AppColors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item['inStock'] ? AppColors.green : AppColors.red,
                            ),
                          ),
                          child: Text(
                            item['inStock'] ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              color: item['inStock'] ? AppColors.green : AppColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Action buttons
              Column(
                children: [
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return IconButton(
                        onPressed: item['inStock'] ? () => _addToCart(item) : null,
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: item['inStock'] ? AppColors.primary : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => _removeFromWishlist(index),
                    icon: const Icon(
                      Icons.favorite,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProduct(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Convert wishlist item to a format compatible with CartProvider
      final product = Product(
        id: item['id'],
        name: item['name'],
        description: 'Product from wishlist',
        price: item['price'].toDouble(),
        imageUrl: item['imageUrl'],
        brand: item['brand'],
        category: item['category'],
        rating: item['rating']?.toDouble(),
        reviewCount: item['reviews'],
        isAvailable: item['inStock'],
      );
      
      await cartProvider.addToCart(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${item['name']} added to cart!')),
              ],
            ),
            backgroundColor: AppColors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _addAllToCart() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      int addedCount = 0;
      
      for (final item in _wishlistItems) {
        if (item['inStock']) {
          final product = Product(
            id: item['id'],
            name: item['name'],
            description: 'Product from wishlist',
            price: item['price'].toDouble(),
            imageUrl: item['imageUrl'],
            brand: item['brand'],
            category: item['category'],
            rating: item['rating']?.toDouble(),
            reviewCount: item['reviews'],
            isAvailable: item['inStock'],
          );
          
          await cartProvider.addToCart(product);
          addedCount++;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$addedCount items added to cart!'),
            backgroundColor: AppColors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add items to cart: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _removeFromWishlist(int index) {
    final item = _wishlistItems[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove from Wishlist', style: AppTextStyles.heading3),
        content: Text('Remove "${item['name']}" from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _wishlistItems.removeAt(index));
              _saveWishlist();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} removed from wishlist'),
                  backgroundColor: AppColors.red,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() => _wishlistItems.insert(index, item));
                      _saveWishlist();
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Wishlist', style: AppTextStyles.heading3),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _wishlistItems.clear());
              _saveWishlist();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wishlist cleared'),
                  backgroundColor: AppColors.red,
                ),
              );
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
}