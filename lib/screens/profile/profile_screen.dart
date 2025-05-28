import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_hub_app/screens/settings/settings_screen.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _birthday;
  File? _profileImage;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _wishlist = [];
  List<Map<String, String>> _paymentMethods = [];
  List<String> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadOrders();
    _loadWishlist();
    _loadPaymentMethods();
    _loadNotifications();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  // ✅ Load Profile Data
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('profile_firstName') ?? '';
      _lastNameController.text = prefs.getString('profile_lastName') ?? '';
      _phoneController.text = prefs.getString('profile_phone') ?? '';
      _bioController.text = prefs.getString('profile_bio') ?? '';
      _addressController.text = prefs.getString('profile_address') ?? '';
      _cityController.text = prefs.getString('profile_city') ?? '';
      _postalController.text = prefs.getString('profile_postal') ?? '';
      _selectedGender = prefs.getString('profile_gender');
      
      final birthdayString = prefs.getString('profile_birthday');
      if (birthdayString != null && birthdayString.isNotEmpty) {
        _birthday = DateTime.tryParse(birthdayString);
      }
      
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  // ✅ Save Profile Data
  Future<void> _saveProfileData() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('profile_firstName', _firstNameController.text);
      await prefs.setString('profile_lastName', _lastNameController.text);
      await prefs.setString('profile_phone', _phoneController.text);
      await prefs.setString('profile_bio', _bioController.text);
      await prefs.setString('profile_address', _addressController.text);
      await prefs.setString('profile_city', _cityController.text);
      await prefs.setString('profile_postal', _postalController.text);
      await prefs.setString('profile_gender', _selectedGender ?? '');
      await prefs.setString('profile_birthday', _birthday?.toIso8601String() ?? '');
      await prefs.setString('profile_image', _profileImage?.path ?? '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Pick Profile Image
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        await _saveProfileData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // ✅ Load Orders (Mock Data)
  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('user_orders');
    
    if (ordersJson != null) {
      setState(() {
        _orders = List<Map<String, dynamic>>.from(jsonDecode(ordersJson));
      });
    } else {
      // Demo orders
      setState(() {
        _orders = [
          {
            'id': 'ORD001',
            'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            'total': 299.99,
            'status': 'Delivered',
            'items': 3,
          },
          {
            'id': 'ORD002',
            'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            'total': 159.99,
            'status': 'Shipped',
            'items': 1,
          },
          {
            'id': 'ORD003',
            'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
            'total': 89.99,
            'status': 'Processing',
            'items': 2,
          },
        ];
      });
      await _saveOrders();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_orders', jsonEncode(_orders));
  }

  // ✅ Load Wishlist
  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('user_wishlist');
    
    if (wishlistJson != null) {
      setState(() {
        _wishlist = List<Map<String, dynamic>>.from(jsonDecode(wishlistJson));
      });
    } else {
      // Demo wishlist
      setState(() {
        _wishlist = [
          {
            'id': 'PROD001',
            'name': 'iPhone 15 Pro',
            'brand': 'Apple',
            'price': 999.99,
            'imageUrl': 'https://via.placeholder.com/100',
          },
          {
            'id': 'PROD002',
            'name': 'MacBook Air M2',
            'brand': 'Apple',
            'price': 1299.99,
            'imageUrl': 'https://via.placeholder.com/100',
          },
        ];
      });
      await _saveWishlist();
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_wishlist', jsonEncode(_wishlist));
  }

  // ✅ Load Payment Methods
  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final methodsJson = prefs.getString('payment_methods');
    
    if (methodsJson != null) {
      setState(() {
        _paymentMethods = List<Map<String, String>>.from(jsonDecode(methodsJson));
      });
    } else {
      // Demo payment method
      setState(() {
        _paymentMethods = [
          {
            'type': 'Credit Card',
            'number': '4532********1234',
            'holder': 'John Doe',
            'expiry': '12/25',
          },
        ];
      });
      await _savePaymentMethods();
    }
  }

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_methods', jsonEncode(_paymentMethods));
  }

  // ✅ Load Notifications
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifJson = prefs.getString('user_notifications');
    
    if (notifJson != null) {
      setState(() {
        _notifications = List<String>.from(jsonDecode(notifJson));
      });
    } else {
      setState(() {
        _notifications = [
          'Your order #ORD001 has been delivered!',
          'Flash Sale: Up to 50% off on electronics!',
          'Welcome to TechHub! Start shopping now.',
          'New arrival: Latest smartphones are here!',
        ];
      });
      await _saveNotifications();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_notifications', jsonEncode(_notifications));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = user?.email == 'admin@techhub.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              // ✅ Navigate to EditProfileScreen instead of showing dialog
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              
              // ✅ Refresh profile data if changes were saved
              if (result == true) {
                await _loadProfileData();
                setState(() {}); // Refresh the UI
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProfileData();
          await _loadOrders();
          await _loadWishlist();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                
                // Profile Stats
                _buildProfileStats(),
                const SizedBox(height: 24),
                
                // Menu Items
                _buildMenuItems(isAdmin),
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    final displayName = _firstNameController.text.isNotEmpty 
        ? '${_firstNameController.text} ${_lastNameController.text}'.trim()
        : user?.displayName ?? 'User';

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null) as ImageProvider?,
                  child: (_profileImage == null && user?.photoURL == null)
                      ? const Icon(Icons.person, size: 50, color: Colors.black)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'example@email.com',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            ),
            if (_bioController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _bioController.text,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('Orders', _orders.length.toString()),
            ),
            Container(width: 1, height: 40, color: AppColors.card),
            Expanded(
              child: _buildStatItem('Wishlist', _wishlist.length.toString()),
            ),
            Container(width: 1, height: 40, color: AppColors.card),
            Expanded(
              child: _buildStatItem('Cards', _paymentMethods.length.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildMenuItems(bool isAdmin) {
    return Card(
      color: AppColors.surface,
      child: Column(
        children: [
          if (isAdmin)
            _buildMenuItem(
              Icons.admin_panel_settings,
              'Admin Dashboard',
              'Manage app and users',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              ),
            ),
          // ✅ Updated to navigate to existing orders screen instead of dialog
          _buildMenuItem(
            Icons.shopping_bag_outlined,
            'My Orders',
            '${_orders.length} orders',
            () => Navigator.pushNamed(context, '/orders'), // Navigate to orders screen
          ),
          _buildMenuItem(
            Icons.favorite_border,
            'Wishlist',
            '${_wishlist.length} items',
            () => Navigator.pushNamed(context, '/wishlist'),
          ),
          _buildMenuItem(
            Icons.credit_card,
            'Payment Methods',
            '${_paymentMethods.length} cards',
            () => Navigator.pushNamed(context, '/payment-methods'),
          ),
          _buildMenuItem(
            Icons.location_on_outlined,
            'Shipping Addresses',
            _addressController.text.isNotEmpty ? 'Configured' : 'Add address',
            () => Navigator.pushNamed(context, '/shipping-addresses'),
          ),
          _buildMenuItem(
            Icons.notifications_outlined,
            'Notifications',
            '${_notifications.length} messages',
            () => _showNotificationsDialog(),
          ),
          _buildMenuItem(
            Icons.help_outline,
            'Help & Support',
            'Contact us',
            () => _showHelpDialog(),
          ),
          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
            'App preferences',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ✅ Payment Methods Dialog
  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Payment Methods', style: AppTextStyles.heading3),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: _paymentMethods.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card, size: 64, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text('No payment methods added', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          return Card(
                            color: AppColors.card,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.credit_card, color: AppColors.primary),
                              title: Text(method['number'] ?? '', style: AppTextStyles.bodyLarge),
                              subtitle: Text('${method['holder']} • Exp: ${method['expiry']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.red),
                                onPressed: () {
                                  setState(() => _paymentMethods.removeAt(index));
                                  _savePaymentMethods();
                                  Navigator.pop(context);
                                  _showPaymentMethodsDialog(); // Refresh dialog
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPaymentMethodDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment Method'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Payment Method', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: cardNumberController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: cardHolderController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Card Holder Name',
                prefixIcon: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiryController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: cvvController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (cardNumberController.text.isNotEmpty &&
                  cardHolderController.text.isNotEmpty &&
                  expiryController.text.isNotEmpty &&
                  cvvController.text.isNotEmpty) {
                setState(() {
                  _paymentMethods.add({
                    'type': 'Credit Card',
                    'number': '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                    'holder': cardHolderController.text,
                    'expiry': expiryController.text,
                  });
                });
                _savePaymentMethods();
                Navigator.pop(context);
                Navigator.pop(context);
                _showPaymentMethodsDialog(); // Refresh main dialog
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  // ✅ Shipping Address Dialog
  void _showShippingAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Shipping Address', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Street Address',
                prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      prefixIcon: Icon(Icons.mail, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveProfileData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ✅ Notifications Dialog
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Notifications', style: AppTextStyles.heading3),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('No notifications', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: AppColors.card,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.notifications, color: AppColors.primary),
                        title: Text(_notifications[index], style: AppTextStyles.bodyMedium),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () {
                            setState(() => _notifications.removeAt(index));
                            _saveNotifications();
                            Navigator.pop(context);
                            _showNotificationsDialog(); // Refresh dialog
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _notifications.clear());
                _saveNotifications();
                Navigator.pop(context);
              },
              child: const Text('Clear All', style: TextStyle(color: AppColors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ✅ Help Dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Help & Support', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact Information:', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'Email', 'support@techhub.com'),
            _buildContactItem(Icons.phone, 'Phone', '+1 (555) 123-4567'),
            _buildContactItem(Icons.access_time, 'Hours', 'Mon-Fri 9AM-6PM'),
            const SizedBox(height: 16),
            const Text(
              'You can also find answers to common questions in our FAQ section or use the in-app chat feature.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ✅ Clear Cache Dialog
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cache', style: AppTextStyles.heading3),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will clear temporary files and free up storage space. Your personal data and settings will be preserved.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Cache size: ~25 MB',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Simulate cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  // ✅ About Dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('About TechHub', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo/Icon
              const Center(
                child: Icon(
                  Icons.shopping_bag,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // App Info
              const Center(
                child: Column(
                  children: [
                    Text('TechHub', style: AppTextStyles.heading2),
                    SizedBox(height: 4),
                    Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              const Text(
                'Your Ultimate Tech Shopping Destination',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'TechHub is your one-stop shop for the latest technology products. From smartphones to laptops, we have everything you need to stay connected and productive.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Features
              const Text('Features:', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              _buildFeatureItem('🛒', 'Easy Shopping Experience'),
              _buildFeatureItem('💳', 'Secure Payment Methods'),
              _buildFeatureItem('🚚', 'Fast Delivery'),
              _buildFeatureItem('💝', 'Wishlist & Favorites'),
              _buildFeatureItem('📱', 'Mobile Optimized'),
              _buildFeatureItem('🔒', 'Privacy Protection'),
              
              const SizedBox(height: 24),
              
              // Contact
              const Text('Contact Us:', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              _buildContactRow(Icons.email, 'support@techhub.com'),
              _buildContactRow(Icons.phone, '+1 (555) 123-4567'),
              _buildContactRow(Icons.language, 'www.techhub.com'),
              
              const SizedBox(height: 16),
              
              // Copyright
              const Center(
                child: Text(
                  '© 2024 TechHub. All rights reserved.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  // ✅ Enhanced helper methods for settings with better error handling
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefKey = 'setting_$key';
      
      if (value is bool) {
        await prefs.setBool(prefKey, value);
      } else if (value is String) {
        await prefs.setString(prefKey, value);
      } else if (value is int) {
        await prefs.setInt(prefKey, value);
      } else if (value is double) {
        await prefs.setDouble(prefKey, value);
      }
      
      print('Setting saved: $key = $value');
    } catch (e) {
      print('Error saving setting $key: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save setting: $key'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<T> _loadSetting<T>(String key, T defaultValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefKey = 'setting_$key';
      
      if (T == bool) {
        return (prefs.getBool(prefKey) ?? defaultValue) as T;
      } else if (T == String) {
        return (prefs.getString(prefKey) ?? defaultValue) as T;
      } else if (T == int) {
        return (prefs.getInt(prefKey) ?? defaultValue) as T;
      } else if (T == double) {
        return (prefs.getDouble(prefKey) ?? defaultValue) as T;
      }
      
      return defaultValue;
    } catch (e) {
      print('Error loading setting $key: $e');
      return defaultValue;
    }
  }

  // ✅ Initialize settings on app start
  Future<void> _initializeSettings() async {
    try {
      // Load all settings and apply them
      final pushNotifications = await _loadSetting('push_notifications', true);
      final darkMode = await _loadSetting('dark_mode', true);
      final language = await _loadSetting('language', 'English');
      
      // Apply settings to app state if needed
      print('Settings loaded - Push: $pushNotifications, Dark: $darkMode, Lang: $language');
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }
  
  // ✅ Privacy Policy Dialog
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy Policy', style: AppTextStyles.heading3),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Collection',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Information Usage',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data Security',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Information Sharing',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this Privacy Policy.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cookies and Tracking',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We use cookies and similar tracking technologies to enhance your experience, analyze usage patterns, and personalize content.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Rights',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Us',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have any questions about this Privacy Policy, please contact us at privacy@techhub.com or call +1 (555) 123-4567.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Last Updated: November 2024',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ✅ Terms of Service Dialog
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Terms of Service', style: AppTextStyles.heading3),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acceptance of Terms',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'By accessing and using TechHub, you accept and agree to be bound by the terms and provision of this agreement.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Use License',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Permission is granted to temporarily download one copy of TechHub per device for personal, non-commercial transitory viewing only. This license shall automatically terminate if you violate any of these restrictions.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'User Account',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You are responsible for safeguarding the password and for all activities that occur under your account. You agree to immediately notify us of any unauthorized use of your account.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prohibited Uses',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You may not use our service for any illegal or unauthorized purpose. You must not violate any laws in your jurisdiction when using the service.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Product Information',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We strive to provide accurate product information, but we do not warrant that product descriptions or other content is accurate, complete, reliable, or error-free.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Terms',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'All payments are processed securely. By providing payment information, you authorize us to charge the specified amount for your purchases.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Shipping and Returns',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Shipping times and costs vary by location and product. Returns are accepted within 30 days of delivery in original condition.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Limitation of Liability',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'In no event shall TechHub or its suppliers be liable for any damages arising out of the use or inability to use the materials on TechHub\'s website.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Governing Law',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'These terms are governed by and construed in accordance with the laws of the jurisdiction in which TechHub operates.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Changes to Terms',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We reserve the right to update these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Information',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Questions about the Terms of Service should be sent to us at legal@techhub.com.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Last Updated: November 2024',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ✅ Logout Dialog
  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout', style: AppTextStyles.heading3),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'You will need to sign in again to access your account.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
                
                // Sign out
                await authProvider.signOut();
                
                // Close loading dialog if still mounted
                if (mounted) {
                  Navigator.pop(context);
                  
                  // Navigate to login screen and clear all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: AppColors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog if error occurs
                if (mounted) {
                  Navigator.pop(context);
                  
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to logout: $e'),
                      backgroundColor: AppColors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.hourglass_empty;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.green;
      case 'shipped':
        return AppColors.orange; // ✅ Use orange instead of yellow
      case 'processing':
        return AppColors.primary;
      case 'pending':
        return AppColors.warning; // ✅ Add pending status
      case 'cancelled':
        return AppColors.red; // ✅ Add cancelled status
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
