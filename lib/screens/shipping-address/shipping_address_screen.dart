import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shipping_address.dart';
import '../../providers/shipping_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/extensions.dart';
import 'add_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  final bool isOrderFlow; // ✅ Add this parameter
  
  const ShippingAddressScreen({
    super.key,
    this.isOrderFlow = false, // ✅ Default to false
  });

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShippingProvider>(context, listen: false).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isOrderFlow ? 'Select Address' : 'Shipping Addresses', // ✅ Dynamic title
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (!widget.isOrderFlow) // ✅ Only show add button when not in order flow
            IconButton(
              onPressed: () => _navigateToAddAddress(),
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
        ],
      ),
      body: Consumer<ShippingProvider>(
        builder: (context, shippingProvider, child) {
          if (shippingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (shippingProvider.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              if (widget.isOrderFlow) // ✅ Show instruction when in order flow
                _buildOrderFlowHeader(),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shippingProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = shippingProvider.addresses[index];
                    return _buildAddressCard(address, shippingProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: widget.isOrderFlow ? FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add New Address'),
      ) : null,
    );
  }

  Widget _buildOrderFlowHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select the address where you want your order delivered',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address, ShippingProvider provider) {
    final isDefault = provider.defaultAddress?.id == address.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault 
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.2),
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.isOrderFlow 
            ? () => _selectAddressForOrder(address) // ✅ Select for order
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Header
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          address.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Default',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!widget.isOrderFlow) // ✅ Only show menu when not in order flow
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleAddressAction(value, address, provider),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        if (!isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 18),
                                SizedBox(width: 8),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AppColors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Full Name
              Text(
                address.fullName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Address Details
              Text(
                address.fullAddress,
                style: AppTextStyles.bodyMedium,
              ),
              
              const SizedBox(height: 4),
              
              // Phone Number
              Text(
                address.phoneNumber,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              if (widget.isOrderFlow) ...[
                const SizedBox(height: 12),
                // Select Button for Order Flow
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectAddressForOrder(address),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDefault ? AppColors.primary : AppColors.card,
                      foregroundColor: isDefault ? Colors.black : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isDefault ? 'Use This Address' : 'Select This Address',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Addresses Added',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isOrderFlow 
                ? 'Add an address to continue with your order'
                : 'Add shipping addresses for faster checkout',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAddress(),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
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

  // ✅ Method to select address for order flow
  void _selectAddressForOrder(ShippingAddress address) {
    Navigator.pop(context, address); // Return selected address
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddShippingAddressScreen(
          isOrderFlow: widget.isOrderFlow, // ✅ Pass the order flow flag
        ),
      ),
    );
    
    if (result != null && result is ShippingAddress && widget.isOrderFlow) {
      // If address was added during order flow, return it
      Navigator.pop(context, result);
    }
  }

  void _handleAddressAction(String action, ShippingAddress address, ShippingProvider provider) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddShippingAddressScreen(
              address: address,
              isOrderFlow: widget.isOrderFlow,
            ),
          ),
        );
        break;
      case 'default':
        provider.setDefaultAddress(address.id);
        break;
      case 'delete':
        _showDeleteDialog(address, provider);
        break;
    }
  }

  void _showDeleteDialog(ShippingAddress address, ShippingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteAddress(address.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}