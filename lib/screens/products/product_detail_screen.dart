import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;
  int selectedImageIndex = 0;
  bool isWishlisted = false;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final product = productProvider.getProductById(widget.productId);

        if (product == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Not Found', style: AppTextStyles.appBarTitle),
              backgroundColor: AppColors.surface,
              iconTheme: const IconThemeData(color: AppColors.primary),
            ),
            backgroundColor: AppColors.background,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red),
                  SizedBox(height: 16),
                  Text('Product not found', style: AppTextStyles.heading3),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Enhanced App Bar with Product Images
                _buildEnhancedAppBar(product),

                // Product Details
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Product Header Section
                      _buildProductHeader(product),
                      
                      // Image Thumbnails
                      _buildImageThumbnails(product),
                      
                      // Product Info Tags
                      _buildProductInfoSection(product),
                      
                      // Size and Color Selection
                      _buildSelectionSection(product),
                      
                      // Quantity and Stock
                      _buildQuantityAndStock(product),
                      
                      // Tabbed Content (Description, Specifications, Reviews)
                      _buildTabbedContent(product),
                      
                      // Related Products
                      _buildRelatedProducts(),
                      
                      const SizedBox(height: 120), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Bottom Action Bar
          bottomSheet: _buildEnhancedBottomBar(product),
        );
      },
    );
  }

  Widget _buildEnhancedAppBar(Product product) {
    final allImages = product.allImages;
    
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.primary),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Main Image with PageView
            PageView.builder(
              itemCount: allImages.length,
              onPageChanged: (index) {
                setState(() {
                  selectedImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'product-${product.id}-$index',
                  child: Image.network(
                    allImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.card,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Discount Badge
            if (product.isOnSale)
              Positioned(
                top: 60,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${product.discount!.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            
            // Image Indicator
            if (allImages.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: selectedImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selectedImageIndex == index
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.primary),
          onPressed: () => _shareProduct(product),
        ),
        IconButton(
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? AppColors.red : AppColors.primary,
          ),
          onPressed: () => _toggleWishlist(product),
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.itemCount > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildProductHeader(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.name,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Brand
          if (product.brand?.isNotEmpty == true)
            Text(
              'by ${product.brand}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Price Section
          Row(
            children: [
              if (product.isOnSale) ...[
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${product.discountedPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.price.copyWith(fontSize: 28),
                ),
                const SizedBox(width: 8),
                Text(
                  'Save \$${product.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.price.copyWith(fontSize: 28),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating and Reviews
          if (product.rating != null) ...[
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < product.rating!.floor()
                          ? Icons.star
                          : index < product.rating!
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.rating!.toStringAsFixed(1)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${product.reviewCount ?? 0} reviews)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showReviews(product),
                  child: const Text('See all reviews'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildImageThumbnails(Product product) {
    final allImages = product.allImages;
    if (allImages.length <= 1) return const SizedBox.shrink();
    
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allImages.length,
        itemBuilder: (context, index) {
          final isSelected = selectedImageIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedImageIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  allImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.card,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfoSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Status
          _buildStockIndicator(product),
          const SizedBox(height: 16),
          
          // Product Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product.category?.isNotEmpty == true)
                _buildInfoChip(Icons.category, product.category!),
              if (product.isFeatured)
                _buildInfoChip(Icons.star, 'Featured'),
              _buildInfoChip(Icons.local_shipping, 'Free Shipping'),
              _buildInfoChip(Icons.verified_user, 'Warranty'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(Product product) {
    Color statusColor;
    IconData statusIcon;
    String statusText = product.stockStatus;
    
    switch (product.stockStatus) {
      case 'Out of Stock':
        statusColor = AppColors.red;
        statusIcon = Icons.close;
        break;
      case 'Low Stock':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        if (product.stockQuantity != null) {
          statusText = 'Only ${product.stockQuantity} left!';
        }
        break;
      default:
        statusColor = AppColors.green;
        statusIcon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSection(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size Selection
          if (product.size?.isNotEmpty == true) ...[
            const Text('Size', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildEnhancedSizeSelector(product),
            const SizedBox(height: 24),
          ],

          // Color Selection
          if (product.color?.isNotEmpty == true) ...[
            const Text('Color', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildEnhancedColorSelector(product),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityAndStock(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quantity', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              _buildEnhancedQuantitySelector(),
            ],
          ),
          const Spacer(),
          if (product.stockQuantity != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Available', style: AppTextStyles.bodySmall),
                Text(
                  '${product.stockQuantity} units',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabbedContent(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Description'),
                Tab(text: 'Specs'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          
          // Tab Content
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(product),
                _buildSpecificationsTab(product),
                _buildReviewsTab(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Price', style: AppTextStyles.bodySmall),
                    Text(
                      '\$${(product.isOnSale ? product.discountedPrice : product.price * quantity).toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                Text(
                  'Qty: $quantity',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('View Cart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: product.isInStock && !cartProvider.isLoading
                            ? () => _addToCart(context, product)
                            : null,
                        icon: cartProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Icon(Icons.add_shopping_cart),
                        label: Text(
                          cartProvider.isLoading
                              ? 'Adding...'
                              : !product.isInStock
                                  ? 'Out of Stock'
                                  : 'Add to Cart',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.isInStock
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Helper Widgets
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSizeSelector(Product product) {
    final sizes = product.size!.contains(',')
        ? product.size!.split(',').map((s) => s.trim()).toList()
        : ['S', 'M', 'L', 'XL'];
    
    return Wrap(
      spacing: 12,
      children: sizes.map((size) {
        final isSelected = selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedColorSelector(Product product) {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'White', 'color': Colors.white},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Red', 'color': Colors.red},
    ];

    return Wrap(
      spacing: 12,
      children: colors.map((colorData) {
        final colorName = colorData['name'] as String;
        final color = colorData['color'] as Color;
        final isSelected = selectedColor == colorName;
        
        return GestureDetector(
          onTap: () => setState(() => selectedColor = colorName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                width: isSelected ? 4 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: color == Colors.white
                ? Icon(Icons.circle, color: Colors.grey[300], size: 30)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
            icon: const Icon(Icons.remove),
            color: quantity > 1 ? AppColors.primary : AppColors.textSecondary,
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => quantity++),
            icon: const Icon(Icons.add),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Tab Content Builders
  Widget _buildDescriptionTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'No description available.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 20),
          const Text('Features:', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ..._getProductFeatures().map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(feature, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab(Product product) {
    final specs = product.specifications ?? _getDefaultSpecifications();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: specs.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Rating Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      product.rating?.toStringAsFixed(1) ?? '4.5',
                      style: AppTextStyles.heading2,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (product.rating?.floor() ?? 4)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '${product.reviewCount ?? 0} reviews',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final stars = 5 - index;
                      return Row(
                        children: [
                          Text('$stars'),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (5 - index) * 0.2,
                              backgroundColor: AppColors.card,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(5 - index) * 20}%'),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Sample Reviews
          ..._getSampleReviews().map((review) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            review['name'][0],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  ...List.generate(review['rating'], (index) => 
                                    const Icon(Icons.star, color: Colors.amber, size: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    review['date'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['comment'],
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You might also like', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Container(
                            color: AppColors.card,
                            child: const Center(
                              child: Icon(Icons.image, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Related Product ${index + 1}',
                              style: AppTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(index + 1) * 99}.99',
                              style: AppTextStyles.price.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<String> _getProductFeatures() {
    return [
      'Premium quality materials',
      'Advanced technology integration',
      'Ergonomic design for comfort',
      'Energy efficient operation',
      '1-year manufacturer warranty',
      'Free shipping and returns',
      '24/7 customer support',
      'Eco-friendly packaging',
    ];
  }

  Map<String, dynamic> _getDefaultSpecifications() {
    return {
      'Brand': 'TechHub',
      'Model': 'TH-2024',
      'Weight': '1.2 kg',
      'Dimensions': '30 x 20 x 5 cm',
      'Material': 'Premium Aluminum',
      'Color Options': 'Multiple',
      'Warranty': '1 Year',
      'Country of Origin': 'USA',
    };
  }

  List<Map<String, dynamic>> _getSampleReviews() {
    return [
      {
        'name': 'John Doe',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Excellent product! Exceeded my expectations. Great build quality and fast delivery.',
      },
      {
        'name': 'Sarah Smith',
        'rating': 4,
        'date': '1 week ago',
        'comment': 'Good value for money. Works as described. Would recommend to others.',
      },
      {
        'name': 'Mike Johnson',
        'rating': 5,
        'date': '2 weeks ago',
        'comment': 'Outstanding quality and performance. This product is worth every penny!',
      },
    ];
  }

  void _shareProduct(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _toggleWishlist(Product product) {
    setState(() {
      isWishlisted = !isWishlisted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWishlisted
              ? '${product.name} added to wishlist'
              : '${product.name} removed from wishlist',
        ),
        backgroundColor: isWishlisted ? AppColors.green : AppColors.textSecondary,
      ),
    );
  }

  void _showReviews(Product product) {
    _tabController.animateTo(2);
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      await cartProvider.addToCart(
        product,
        quantity: quantity,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${product.name} added to cart!'),
                ),
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
}