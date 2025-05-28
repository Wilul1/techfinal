import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Track Order #${widget.order.id}', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummary(),
            
            const SizedBox(height: 20),
            
            // Tracking Information
            _buildTrackingInfo(),
            
            const SizedBox(height: 20),
            
            // Timeline
            _buildTrackingTimeline(),
            
            const SizedBox(height: 20),
            
            // Delivery Information
            _buildDeliveryInfo(),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.order.statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: widget.order.statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.statusText,
                      style: AppTextStyles.heading3.copyWith(
                        color: widget.order.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.order.items.length} ${widget.order.items.length == 1 ? 'item' : 'items'} • \$${widget.order.total.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Placed on ${_formatDate(widget.order.createdAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.order.estimatedDelivery != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Expected delivery: ${_formatDate(widget.order.estimatedDelivery!)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Information', style: AppTextStyles.heading3),
          
          const SizedBox(height: 16),
          
          if (widget.order.trackingNumber != null) ...[
            // Tracking Number
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, 
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking Number',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.order.trackingNumber!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _copyTrackingNumber,
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy tracking number',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
          ],
          
          // Carrier Information
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Shipped via Express Delivery',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final trackingEvents = _getTrackingEvents();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Timeline', style: AppTextStyles.heading3),
          const SizedBox(height: 20),
          
          ...trackingEvents.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == trackingEvents.length - 1;
            
            return _buildTimelineItem(
              event['title']!,
              event['description']!,
              event['time']!,
              event['completed'] as bool,
              isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    String time,
    bool completed,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot and line
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: completed ? AppColors.primary : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed ? AppColors.primary : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, color: Colors.black, size: 12)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: completed ? AppColors.primary : AppColors.card,
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Event details
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: completed ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Address', style: AppTextStyles.heading3),
          
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.shippingAddress.fullName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.shippingAddress.fullAddress,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.shippingAddress.phoneNumber,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Contact Support
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _contactSupport,
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Refresh Tracking
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _refreshTracking,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Tracking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  IconData _getStatusIcon() {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
    }
  }

  List<Map<String, dynamic>> _getTrackingEvents() {
    // Generate tracking events based on order status
    List<Map<String, dynamic>> events = [
      {
        'title': 'Order Placed',
        'description': 'Your order has been received and is being processed',
        'time': _formatDateTime(widget.order.createdAt),
        'completed': true,
      },
    ];

    if (widget.order.status.index >= OrderStatus.confirmed.index) {
      events.add({
        'title': 'Order Confirmed',
        'description': 'Your order has been confirmed and is being prepared',
        'time': _formatDateTime(widget.order.updatedAt ?? widget.order.createdAt.add(const Duration(hours: 1))),
        'completed': true,
      });
    }

    if (widget.order.status.index >= OrderStatus.processing.index) {
      events.add({
        'title': 'Processing',
        'description': 'Your items are being picked and packed',
        'time': _formatDateTime(widget.order.updatedAt ?? widget.order.createdAt.add(const Duration(hours: 2))),
        'completed': true,
      });
    }

    if (widget.order.status.index >= OrderStatus.shipped.index) {
      events.add({
        'title': 'Shipped',
        'description': 'Your order is on its way to you',
        'time': _formatDateTime(widget.order.updatedAt ?? widget.order.createdAt.add(const Duration(days: 1))),
        'completed': true,
      });
    }

    if (widget.order.status.index >= OrderStatus.delivered.index) {
      events.add({
        'title': 'Delivered',
        'description': 'Your order has been delivered successfully',
        'time': _formatDateTime(widget.order.updatedAt ?? widget.order.createdAt.add(const Duration(days: 3))),
        'completed': true,
      });
    } else {
      // Add upcoming delivery event
      events.add({
        'title': 'Out for Delivery',
        'description': 'Your package is out for delivery',
        'time': 'Expected today',
        'completed': false,
      });
    }

    return events;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyTrackingNumber() async {
    if (widget.order.trackingNumber != null) {
      await Clipboard.setData(ClipboardData(text: widget.order.trackingNumber!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking number copied to clipboard'),
            backgroundColor: AppColors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Contact Support'),
        content: const Text(
          'Need help with your order? Our support team is here to help!\n\n'
          'Email: support@techhub.com\n'
          'Phone: 1-800-TECH-HUB\n'
          'Hours: 9 AM - 6 PM, Mon-Fri',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you could implement actual contact functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecting to support...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Contact Now'),
          ),
        ],
      ),
    );
  }

  void _refreshTracking() {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16),
            Text('Refreshing tracking information...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate refresh delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking information updated'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    });
  }
}