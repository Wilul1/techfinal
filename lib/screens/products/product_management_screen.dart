import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  bool _isFeatured = false;
  File? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _imageUrlController.text = picked.path; // Store local path
      });
    }
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: '', // Firestore will assign ID
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        imageUrl: _imageUrlController.text.trim(),
        size: _sizeController.text.trim(),
        color: _colorController.text.trim(),
        brand: '',
        description: '',
        category: '',
        isFeatured: _isFeatured,
      );
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).addProduct(product);
      _nameController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _sizeController.clear();
      _colorController.clear();
      setState(() {
        _isFeatured = false;
        _pickedImage = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product added!')));
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: const Color(0xFF3ABEFF),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF4F8FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter name'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter price'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Pick Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3ABEFF),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_pickedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _pickedImage!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(labelText: 'Size'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: const InputDecoration(labelText: 'Color'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isFeatured,
                        onChanged: (val) {
                          setState(() {
                            _isFeatured = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF3ABEFF),
                      ),
                      const Text('Featured Product'),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3ABEFF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Product'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Product List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232B3A),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  Widget imageWidget;
                  if (product.imageUrl.isNotEmpty &&
                      File(product.imageUrl).existsSync()) {
                    imageWidget = Image.file(
                      File(product.imageUrl),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  } else if (product.imageUrl.isNotEmpty) {
                    imageWidget = Image.network(
                      product.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  } else {
                    imageWidget = const Icon(Icons.image, size: 40);
                  }
                  return Card(
                    child: ListTile(
                      leading: imageWidget,
                      title: Text(product.name),
                      subtitle: Text(
                        '₱${product.price} | Size: ${product.size} | Color: ${product.color}${product.isFeatured ? " | Featured" : ""}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
