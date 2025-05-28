import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/shipping_address.dart';
import '../../providers/shipping_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class AddShippingAddressScreen extends StatefulWidget {
  final ShippingAddress? address;
  final bool isEditing;
  final bool isOrderFlow;

  const AddShippingAddressScreen({
    super.key,
    this.address,
    this.isEditing = false,
    this.isOrderFlow = false,
  });

  @override
  State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  String _selectedType = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;

  final List<String> _addressTypes = ['Home', 'Work', 'Office', 'Other'];
  final List<String> _countries = ['United States', 'Canada', 'United Kingdom', 'Australia'];

  @override
  void initState() {
    super.initState();
    _countryController.text = 'United States';
    
    if (widget.isEditing && widget.address != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final address = widget.address!;
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phoneNumber;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2 ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _countryController.text = address.country;
    _selectedType = address.type;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Address' : 'Add New Address',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator for Order Flow
          if (widget.isOrderFlow) _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Type Selection
                    _buildAddressTypeSection(),
                    const SizedBox(height: 24),

                    // Contact Information
                    _buildContactSection(),
                    const SizedBox(height: 24),

                    // Address Information
                    _buildAddressSection(),
                    const SizedBox(height: 24),

                    // Default Address Toggle
                    _buildDefaultToggle(),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            widget.isOrderFlow ? 'Step 1 of 3 - Shipping Address' : 'Address Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address Type', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: _addressTypes.map((type) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      color: _selectedType == type ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: _selectedType == type ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                value: type,
                groupValue: _selectedType,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _selectedType = value!),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Information', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        
        // Full Name
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter your full name';
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: 16),
        
        // Phone Number
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\(\)\s]')),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter your phone number';
            if (value!.length < 10) return 'Please enter a valid phone number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address Details', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        
        // Address Line 1
        _buildTextField(
          controller: _addressLine1Controller,
          label: 'Address Line 1',
          icon: Icons.location_on,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter your address';
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: 16),
        
        // Address Line 2 (Optional)
        _buildTextField(
          controller: _addressLine2Controller,
          label: 'Address Line 2 (Optional)',
          icon: Icons.location_on_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: 16),
        
        // City and State Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter city';
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State',
                icon: Icons.map,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter state';
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Postal Code and Country Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                icon: Icons.local_post_office,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter postal code';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _countryController.text.isNotEmpty ? _countryController.text : null,
      decoration: InputDecoration(
        labelText: 'Country',
        prefixIcon: const Icon(Icons.public, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: _countries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text(country),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _countryController.text = value ?? '';
        });
      },
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please select a country';
        return null;
      },
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            _isDefault ? Icons.star : Icons.star_border,
            color: _isDefault ? Colors.amber : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set as Default Address',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Use this address as your default shipping address',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            if (widget.isEditing) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: widget.isEditing ? 2 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Update Address' : 'Save Address',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
      case 'office':
        return Icons.business;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ShippingProvider>(context, listen: false);
      
      final address = ShippingAddress(
        id: widget.isEditing ? widget.address!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isNotEmpty 
            ? _addressLine2Controller.text.trim() 
            : null,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        type: _selectedType,
        isDefault: _isDefault,
        createdAt: widget.isEditing ? widget.address!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditing) {
        await provider.updateAddress(address);
      } else {
        await provider.addAddress(address);
      }

      if (mounted) {
        if (widget.isOrderFlow) {
          // Return the new/updated address for order flow
          Navigator.pop(context, address);
        } else {
          // Normal navigation
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text(
          'Are you sure you want to delete this ${_selectedType.toLowerCase()} address?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteAddress();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress() async {
    if (!widget.isEditing || widget.address == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ShippingProvider>(context, listen: false);
      await provider.deleteAddress(widget.address!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: AppColors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete address: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}