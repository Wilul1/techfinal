import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/payment_method.dart';
import '../../providers/payment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final bool isEditing;
  final bool isOrderFlow;

  const AddPaymentMethodScreen({
    super.key,
    this.paymentMethod,
    this.isEditing = false,
    this.isOrderFlow = false,
  });

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _billingAddressController = TextEditingController();

  PaymentMethodType _selectedType = PaymentMethodType.creditCard;
  bool _isDefault = false;
  bool _isLoading = false;
  String _cardBrand = '';

  final List<PaymentMethodType> _paymentTypes = [
    PaymentMethodType.creditCard,
    PaymentMethodType.debitCard,
    PaymentMethodType.paypal,
    PaymentMethodType.applePay,
    PaymentMethodType.googlePay,
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.paymentMethod != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final method = widget.paymentMethod!;
    _cardNumberController.text = method.cardNumber;
    _cardHolderController.text = method.cardHolderName;
    _expiryController.text = method.expiryDate;
    _cvvController.text = method.cvv ?? '';
    _billingAddressController.text = method.billingAddress ?? '';
    _selectedType = method.type;
    _isDefault = method.isDefault;
    _cardBrand = method.cardBrand;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Payment Method' : 'Add Payment Method',
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
                    // Payment Type Selection
                    _buildPaymentTypeSection(),
                    const SizedBox(height: 24),

                    // Card Information
                    if (_selectedType == PaymentMethodType.creditCard || 
                        _selectedType == PaymentMethodType.debitCard) ...[
                      _buildCardInformationSection(),
                      const SizedBox(height: 24),
                    ],

                    // Alternative Payment Methods
                    if (_selectedType == PaymentMethodType.paypal ||
                        _selectedType == PaymentMethodType.applePay ||
                        _selectedType == PaymentMethodType.googlePay) ...[
                      _buildAlternativePaymentSection(),
                      const SizedBox(height: 24),
                    ],

                    // Billing Address (Optional)
                    _buildBillingAddressSection(),
                    const SizedBox(height: 24),

                    // Default Payment Toggle
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
          const Icon(Icons.payment, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            widget.isOrderFlow ? 'Step 2 of 3 - Payment Method' : 'Payment Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method Type', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: _paymentTypes.map((type) {
              return RadioListTile<PaymentMethodType>(
                title: Row(
                  children: [
                    Icon(
                      _getPaymentTypeIcon(type),
                      color: _selectedType == type ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPaymentTypeName(type),
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

  Widget _buildCardInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card Information', style: AppTextStyles.heading3),
        const SizedBox(height: 12),

        // Card Number
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            _CardNumberFormatter(),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter card number';
            final cleanValue = value!.replaceAll(' ', '');
            if (cleanValue.length < 13) return 'Please enter a valid card number';
            return null;
          },
          onChanged: (value) {
            setState(() {
              _cardBrand = _getCardBrand(value);
            });
          },
          suffix: _cardBrand.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _cardBrand,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),

        const SizedBox(height: 16),

        // Card Holder Name
        _buildTextField(
          controller: _cardHolderController,
          label: 'Card Holder Name',
          icon: Icons.person,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter card holder name';
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Expiry and CVV Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryController,
                label: 'MM/YY',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter expiry date';
                  if (value!.length < 5) return 'Please enter valid date';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter CVV';
                  if (value!.length < 3) return 'Please enter valid CVV';
                  return null;
                },
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlternativePaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_getPaymentTypeName(_selectedType)} Information', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                _getPaymentTypeIcon(_selectedType),
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Connect your ${_getPaymentTypeName(_selectedType)} account',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You will be redirected to ${_getPaymentTypeName(_selectedType)} to complete the setup',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _connectAlternativePayment(),
                icon: Icon(_getPaymentTypeIcon(_selectedType)),
                label: Text('Connect ${_getPaymentTypeName(_selectedType)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Billing Address', style: AppTextStyles.heading3),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Optional',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _billingAddressController,
          label: 'Billing Address',
          icon: Icons.location_on,
          maxLines: 3,
          textCapitalization: TextCapitalization.words,
        ),
      ],
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
                  'Set as Default Payment Method',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Use this payment method as your default for orders',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffix,
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
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      maxLines: maxLines,
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
                onPressed: _isLoading ? null : _savePaymentMethod,
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
                        widget.isEditing ? 'Update Payment Method' : 'Save Payment Method',
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
  IconData _getPaymentTypeIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.debitCard:
        return Icons.credit_card_outlined;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.applePay:
        return Icons.phone_iphone;
      case PaymentMethodType.googlePay:
        return Icons.phone_android;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _getPaymentTypeName(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _getCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) return 'Visa';
    if (cleanNumber.startsWith('5')) return 'Mastercard';
    if (cleanNumber.startsWith('3')) return 'Amex';
    return '';
  }

  Future<void> _connectAlternativePayment() async {
    // Mock connection process
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getPaymentTypeName(_selectedType)} connected successfully'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      
      final paymentMethod = PaymentMethod(
        id: widget.isEditing ? widget.paymentMethod!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        cardNumber: _cardNumberController.text.trim(),
        cardHolderName: _cardHolderController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cvv: _cvvController.text.trim().isNotEmpty ? _cvvController.text.trim() : null,
        billingAddress: _billingAddressController.text.trim().isNotEmpty ? _billingAddressController.text.trim() : null,
        isDefault: _isDefault,
        createdAt: widget.isEditing ? widget.paymentMethod!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditing) {
        await provider.updatePaymentMethod(paymentMethod);
      } else {
        await provider.addPaymentMethod(paymentMethod);
      }

      if (mounted) {
        if (widget.isOrderFlow) {
          // Return the new/updated payment method for order flow
          Navigator.pop(context, paymentMethod);
        } else {
          // Normal navigation
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save payment method: $e'),
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
        title: const Text('Delete Payment Method'),
        content: Text(
          'Are you sure you want to delete this ${_getPaymentTypeName(_selectedType)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deletePaymentMethod();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePaymentMethod() async {
    if (!widget.isEditing || widget.paymentMethod == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      await provider.deletePaymentMethod(widget.paymentMethod!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method deleted successfully'),
            backgroundColor: AppColors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment method: $e'),
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

// Custom Input Formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}