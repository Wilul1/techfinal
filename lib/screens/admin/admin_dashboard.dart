import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../config/routes.dart';
import 'admin_account_creator.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverview(),
    const ProductManagement(),
    const UserManagement(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                  break;
                case 'logout':
                  await authProvider.signOut();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Dashboard Overview Page
class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: AppTextStyles.heading2),
          const SizedBox(height: 20),
          
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Products', '150', Icons.inventory, AppColors.green),
              _buildStatCard('Total Users', '1,234', Icons.people, AppColors.purple),
              _buildStatCard('Orders Today', '45', Icons.shopping_cart, AppColors.yellow),
              _buildStatCard('Revenue', '\$12,345', Icons.attach_money, AppColors.primary),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          const Text('Quick Actions', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                context,
                'Add Product',
                Icons.add_shopping_cart,
                () => Navigator.of(context).pushNamed('/admin/add-product'),
              ),
              _buildActionButton(
                context,
                'Create Admin',
                Icons.admin_panel_settings,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminAccountCreator()),
                ),
              ),
              _buildActionButton(
                context,
                'View Orders',
                Icons.list_alt,
                () => Navigator.of(context).pushNamed('/admin/orders'),
              ),
              _buildActionButton(
                context,
                'Analytics',
                Icons.analytics,
                () => Navigator.of(context).pushNamed('/admin/analytics'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// Product Management Page
class ProductManagement extends StatelessWidget {
  const ProductManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Products', style: AppTextStyles.heading2),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add product screen
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: AppColors.card,
                                child: const Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          title: Text(product.name, style: AppTextStyles.bodyLarge),
                          subtitle: Text('\$${product.price}', style: AppTextStyles.price),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: AppColors.primary),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: AppColors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              switch (value) {
                                case 'edit':
                                  // TODO: Navigate to edit product screen
                                  break;
                                case 'delete':
                                  // TODO: Show delete confirmation dialog
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// User Management Page
class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('User Management', style: AppTextStyles.heading3),
          SizedBox(height: 8),
          Text('Coming Soon...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: AppTextStyles.heading2),
          const SizedBox(height: 20),
          
          Card(
            color: AppColors.surface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                  title: const Text('Create Admin Account'),
                  subtitle: const Text('Add new administrator'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminAccountCreator()),
                  ),
                ),
                const Divider(color: AppColors.card),
                ListTile(
                  leading: const Icon(Icons.backup, color: AppColors.green),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Export application data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement backup functionality
                  },
                ),
                const Divider(color: AppColors.card),
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.yellow),
                  title: const Text('App Information'),
                  subtitle: const Text('Version and details'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Show app info dialog
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}