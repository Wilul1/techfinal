import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Product management state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _pickedImage;
  String? _imageUrl;
  String? _editProductId;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final ref = _storage.ref().child(
      'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _addOrEditProduct() async {
    setState(() => isLoading = true);
    try {
      String? imageUrl = _imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
      }
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (_editProductId == null) {
        await _firestore.collection('products').add(data);
      } else {
        await _firestore
            .collection('products')
            .doc(_editProductId)
            .update(data);
      }
      _clearProductForm();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearProductForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _pickedImage = null;
    _imageUrl = null;
    _editProductId = null;
    setState(() {});
  }

  Future<void> _editProduct(DocumentSnapshot doc) async {
    _nameController.text = doc['name'] ?? '';
    _descController.text = doc['description'] ?? '';
    _priceController.text = doc['price'].toString();
    _imageUrl = doc['imageUrl'];
    _editProductId = doc.id;
    setState(() {});
  }

  Future<void> _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14171C),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF181C23),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Row(
                  children: [
                    const SizedBox(width: 18),
                    Image.asset(
                      'assets/banners/techhubnexus.png',
                      width: 36,
                      height: 36,
                      errorBuilder:
                          (_, __, ___) =>
                              Icon(Icons.dashboard, color: Color(0xFF00D1FF)),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TechHub Admin',
                      style: TextStyle(
                        color: Color(0xFF00D1FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _adminNavItem(Icons.dashboard, 'Dashboard', selected: true),
                _adminNavItem(Icons.people, 'Users', badge: 12),
                _adminNavItem(Icons.shopping_bag, 'Products'),
                _adminNavItem(Icons.notifications, 'Notifications', badge: 3),
                _adminNavItem(Icons.settings, 'Settings'),
                _adminNavItem(Icons.bar_chart, 'Logs & Reports'),
                // Add Product button (admin only, in sidebar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Color(0xFF00D1FF)),
                      label: const Text(
                        'Add Product',
                        style: TextStyle(
                          color: Color(0xFF00D1FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF232A34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF00D1FF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _AddProductDialog(),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                _adminNavItem(Icons.logout, 'Logout', onTap: _logout),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: const Color(0xFF181C23),
              child: Column(
                children: [
                  // Top bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF232A34),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 320,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search anything... ',
                              hintStyle: const TextStyle(
                                color: Color(0xFF6C7A89),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF00D1FF),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF181C23),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: Color(0xFF00D1FF),
                              ),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF00D1FF),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Admin',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF6C7A89),
                        ),
                      ],
                    ),
                  ),
                  // Dashboard cards
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 32,
                        mainAxisSpacing: 32,
                        childAspectRatio: 2.2,
                        children: [
                          _dashboardCard(
                            Icons.person,
                            'Total Users',
                            '12,845',
                            '+12.5%',
                            Colors.blue,
                          ),
                          _dashboardCard(
                            Icons.people,
                            'Active Users',
                            '8,932',
                            '+8.2%',
                            Colors.green,
                          ),
                          _dashboardCard(
                            Icons.shopping_bag,
                            'Products',
                            '1,234',
                            '+23.1%',
                            Colors.purple,
                          ),
                          _dashboardCard(
                            Icons.attach_money,
                            'Revenue',
                            '₱1,200,000',
                            '+5.7%',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminNavItem(
    IconData icon,
    String label, {
    bool selected = false,
    int? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF232A34) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF00D1FF) : Colors.white,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF00D1FF) : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    IconData icon,
    String label,
    String value,
    String change,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF232A34),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6C7A89),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                change,
                style: const TextStyle(
                  color: Color(0xFF00D1FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  @override
  __AddProductDialogState createState() => __AddProductDialogState();
}

class __AddProductDialogState extends State<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _submitProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      // Simulate saving product details
      final newProduct = {
        'name': _nameController.text,
        'description': _descController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imagePath': _pickedImage?.path,
        'isFeatured': true, // Mark as featured
      };

      // Add the product to Firestore and mark it as featured
      FirebaseFirestore.instance
          .collection('products')
          .add({...newProduct, 'createdAt': FieldValue.serverTimestamp()})
          .then((_) {
            print('Product added to Firestore and marked as featured');
            Navigator.pop(context);
          })
          .catchError((error) {
            print('Failed to add product: $error');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a product name'
                            : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a price'
                            : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _pickedImage == null
                          ? const Center(
                            child: Text(
                              'Upload Image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : Image.file(_pickedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
