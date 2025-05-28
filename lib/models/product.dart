import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? category;
  final String? brand;
  final String? size;
  final String? color;
  final List<String>? images;
  final Map<String, dynamic>? specifications;
  final double? rating;
  final int? reviewCount;
  final int? stockQuantity;
  final bool isAvailable;
  final bool isFeatured;
  final double? discount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category,
    this.brand,
    this.size,
    this.color,
    this.images,
    this.specifications,
    this.rating,
    this.reviewCount,
    this.stockQuantity,
    this.isAvailable = true,
    this.isFeatured = false,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ Factory constructor for creating Product from Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'],
      brand: data['brand'],
      size: data['size'],
      color: data['color'],
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      specifications: data['specifications'],
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount']?.toInt(),
      stockQuantity: data['stockQuantity']?.toInt(),
      isAvailable: data['isAvailable'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      discount: data['discount']?.toDouble(),
      createdAt: data['createdAt'] != null ? 
        (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? 
        (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  // ✅ Factory constructor for creating Product from JSON (for API calls)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      category: json['category'],
      brand: json['brand'],
      size: json['size'],
      color: json['color'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      specifications: json['specifications'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount']?.toInt(),
      stockQuantity: json['stockQuantity']?.toInt(),
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      discount: json['discount']?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // ✅ Convert Product to Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'size': size,
      'color': color,
      'images': images,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'discount': discount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'size': size,
      'color': color,
      'images': images,
      'specifications': specifications,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'discount': discount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to check if product has a specific property
  bool hasProperty(String property) {
    switch (property) {
      case 'discount':
        return discount != null && discount! > 0;
      case 'rating':
        return rating != null;
      case 'brand':
        return brand != null && brand!.isNotEmpty;
      case 'category':
        return category != null && category!.isNotEmpty;
      case 'size':
        return size != null && size!.isNotEmpty;
      case 'color':
        return color != null && color!.isNotEmpty;
      case 'specifications':
        return specifications != null && specifications!.isNotEmpty;
      case 'images':
        return images != null && images!.isNotEmpty;
      case 'stockQuantity':
        return stockQuantity != null;
      default:
        return false;
    }
  }

  // Get discounted price if discount exists
  double get discountedPrice {
    if (discount != null && discount! > 0) {
      return price * (1 - discount! / 100);
    }
    return price;
  }

  // Check if product is on sale
  bool get isOnSale => discount != null && discount! > 0;

  // Get discount amount in currency
  double get discountAmount {
    if (discount != null && discount! > 0) {
      return price * (discount! / 100);
    }
    return 0;
  }

  // Check if product is in stock
  bool get isInStock {
    if (stockQuantity != null) {
      return stockQuantity! > 0;
    }
    return isAvailable;
  }

  // Get stock status text
  String get stockStatus {
    if (!isAvailable) return 'Out of Stock';
    if (stockQuantity != null) {
      if (stockQuantity! <= 0) return 'Out of Stock';
      if (stockQuantity! <= 5) return 'Low Stock';
      return 'In Stock';
    }
    return 'Available';
  }

  // Get all product images including main image
  List<String> get allImages {
    List<String> allImagesList = [imageUrl];
    if (images != null) {
      allImagesList.addAll(images!);
    }
    return allImagesList.toSet().toList(); // Remove duplicates
  }

  // Get rating display text
  String get ratingDisplay {
    if (rating != null) {
      return '${rating!.toStringAsFixed(1)} (${reviewCount ?? 0} reviews)';
    }
    return 'No reviews yet';
  }

  // Copy with method for creating modified copies
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? brand,
    String? size,
    String? color,
    List<String>? images,
    Map<String, dynamic>? specifications,
    double? rating,
    int? reviewCount,
    int? stockQuantity,
    bool? isAvailable,
    bool? isFeatured,
    double? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      color: color ?? this.color,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }
}