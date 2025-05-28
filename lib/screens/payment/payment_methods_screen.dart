import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_method.dart';
import '../../providers/payment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final bool isOrderFlow; // ✅ Add this parameter
  
  const PaymentMethodsScreen({
    super.key,
    this.isOrderFlow = false, // ✅ Default to false
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).loadPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isOrderFlow ? 'Select Payment Method' : 'Payment Methods', // ✅ Dynamic title
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (!widget.isOrderFlow) // ✅ Only show add button when not in order flow
            IconButton(
              onPressed: () => _navigateToAddPaymentMethod(),
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (paymentProvider.paymentMethods.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              if (widget.isOrderFlow) // ✅ Show instruction when in order flow
                _buildOrderFlowHeader(),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentProvider.paymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod = paymentProvider.paymentMethods[index];
                    return _buildPaymentMethodCard(paymentMethod, paymentProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: widget.isOrderFlow ? FloatingActionButton.extended(
        onPressed: () => _navigateToAddPaymentMethod(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add New Card'),
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
              'Choose how you want to pay for your order',
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

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod, PaymentProvider provider) {
    final isDefault = provider.defaultPaymentMethod?.id == paymentMethod.id;
    
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
            ? () => _selectPaymentMethodForOrder(paymentMethod) // ✅ Select for order
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header
              Row(
                children: [
                  // Card Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCardColor(paymentMethod.cardBrand).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCardIcon(paymentMethod.cardBrand),
                      color: _getCardColor(paymentMethod.cardBrand),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              paymentMethod.cardBrand,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentMethod.maskedNumber,
                              style: AppTextStyles.bodyMedium,
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
                        Text(
                          paymentMethod.cardHolderName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (!widget.isOrderFlow) // ✅ Only show menu when not in order flow
                    PopupMenuButton<String>(
                      onSelected: (value) => _handlePaymentMethodAction(value, paymentMethod, provider),
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
              
              // Expiry Date
              Text(
                'Expires ${paymentMethod.expiryDate.toString().padLeft(2, '0')}/${paymentMethod.expiryDate}',
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
                    onPressed: () => _selectPaymentMethodForOrder(paymentMethod),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDefault ? AppColors.primary : AppColors.card,
                      foregroundColor: isDefault ? Colors.black : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isDefault ? 'Use This Card' : 'Select This Card',
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
            Icons.credit_card_off,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Payment Methods',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isOrderFlow 
                ? 'Add a payment method to complete your order'
                : 'Add payment methods for faster checkout',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddPaymentMethod(),
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
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

  // ✅ Method to select payment method for order flow
  void _selectPaymentMethodForOrder(PaymentMethod paymentMethod) {
    Navigator.pop(context, paymentMethod); // Return selected payment method
  }

  void _navigateToAddPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodScreen(
          isOrderFlow: widget.isOrderFlow, // ✅ Pass the order flow flag
        ),
      ),
    );
    
    if (result != null && result is PaymentMethod && widget.isOrderFlow) {
      // If payment method was added during order flow, return it
      Navigator.pop(context, result);
    }
  }

  void _handlePaymentMethodAction(String action, PaymentMethod paymentMethod, PaymentProvider provider) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPaymentMethodScreen(
              paymentMethod: paymentMethod,
              isOrderFlow: widget.isOrderFlow,
            ),
          ),
        );
        break;
      case 'default':
        provider.setDefaultPaymentMethod(paymentMethod.id);
        break;
      case 'delete':
        _showDeleteDialog(paymentMethod, provider);
        break;
    }
  }

  void _showDeleteDialog(PaymentMethod paymentMethod, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this ${paymentMethod.cardBrand} card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deletePaymentMethod(paymentMethod.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // Helper methods for card styling
  IconData _getCardIcon(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Color _getCardColor(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.red;
      case 'amex':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}