import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFFFD700); // Gold
  static const Color primaryDark = Color(0xFFB8860B); // Dark Gold
  static const Color secondary = Color(0xFF2196F3); // Blue
  static const Color purple = Color(0xFF9C27B0); // Purple
  
  // Background colors
  static const Color background = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFF1E1E1E); // Card background
  static const Color card = Color(0xFF2A2A2A); // Elevated card
  
  // Text colors
  static const Color text = Color(0xFFFFFFFF); // Primary text (white)
  static const Color textPrimary = Color(0xFFFFFFFF); // Primary text
  static const Color textSecondary = Color(0xFFB0B0B0); // Secondary text (gray)
  static const Color textDisabled = Color(0xFF757575); // Disabled text
  
  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color green = Color(0xFF4CAF50); // Green (alias)
  static const Color error = Color(0xFFF44336); // Red
  static const Color red = Color(0xFFF44336); // Red (alias)
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color orange = Color(0xFFFF9800); // Orange (alias)
  static const Color yellow = Color(0xFFFFC107); // Yellow
  static const Color info = Color(0xFF2196F3); // Blue
  static const Color blue = Color(0xFF2196F3); // Blue (alias)
  
  // Additional colors
  static const Color divider = Color(0xFF404040); // Divider
  static const Color border = Color(0xFF404040); // Border
  static const Color shadow = Color(0x1A000000); // Shadow
  
  // Input colors
  static const Color inputFill = Color(0xFF2A2A2A); // Input background
  static const Color inputBorder = Color(0xFF404040); // Input border
  static const Color inputFocused = Color(0xFFFFD700); // Focused input border
  
  // Button colors
  static const Color buttonDisabled = Color(0xFF404040); // Disabled button
  static const Color buttonText = Color(0xFF000000); // Button text (black on gold)
  
  // Special colors for order status
  static const Color pending = Color(0xFFFF9800); // Orange
  static const Color confirmed = Color(0xFF2196F3); // Blue
  static const Color processing = Color(0xFF9C27B0); // Purple
  static const Color shipped = Color(0xFF00BCD4); // Cyan
  static const Color delivered = Color(0xFF4CAF50); // Green
  static const Color cancelled = Color(0xFFF44336); // Red
  static const Color refunded = Color(0xFF607D8B); // Blue Gray
  
  // ✅ Gradient colors for splash screen
  static const Color accent1 = Color(0xFF6A1B9A); // Deep Purple
  static const Color accent2 = Color(0xFF8E24AA); // Medium Purple
  static const Color neonPurple = Color(0xFFAB47BC); // Light Purple
}