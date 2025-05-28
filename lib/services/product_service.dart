import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get all products
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get products: $error');
        });
  }

  // Get featured products
  Stream<List<Product>> getFeaturedProducts() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get featured products: $error');
        });
  }

  // Get products by brand
  Stream<List<Product>> getProductsByBrand(String brand) {
    return _firestore
        .collection(_collection)
        .where('brand', isEqualTo: brand)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get products by brand: $error');
        });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get products by category: $error');
        });
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // ✅ Updated add product method to use toFirestore()
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...product.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // ✅ Enhanced update product method
  Future<void> updateProduct(String id, Product product) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...product.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Update specific fields
  Future<void> updateProductFields(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ✅ Enhanced search products method
  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) {
      return getAllProducts();
    }

    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();
    
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) =>
                product.name.toLowerCase().contains(lowercaseQuery) ||
                (product.brand?.toLowerCase().contains(lowercaseQuery) ?? false) ||
                (product.category?.toLowerCase().contains(lowercaseQuery) ?? false) ||
                product.description.toLowerCase().contains(lowercaseQuery))
            .toList())
        .handleError((error) {
          throw Exception('Failed to search products: $error');
        });
  }

  // Get products with pagination
  Future<List<Product>> getProductsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get paginated products: $e');
    }
  }

  // Get products by price range
  Stream<List<Product>> getProductsByPriceRange(double minPrice, double maxPrice) {
    return _firestore
        .collection(_collection)
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get products by price range: $error');
        });
  }

  // Get top-rated products
  Stream<List<Product>> getTopRatedProducts({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThan: 4.0)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get top-rated products: $error');
        });
  }

  // Get products on sale
  Stream<List<Product>> getProductsOnSale() {
    return _firestore
        .collection(_collection)
        .where('discount', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList())
        .handleError((error) {
          throw Exception('Failed to get products on sale: $error');
        });
  }

  // Update product stock
  Future<void> updateProductStock(String id, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'stockQuantity': newStock,
        'isAvailable': newStock > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  // Batch update products
  Future<void> batchUpdateProducts(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();
      
      for (final update in updates) {
        final docRef = _firestore.collection(_collection).doc(update['id']);
        batch.update(docRef, {
          ...update['data'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update products: $e');
    }
  }
}