import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _darkMode = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('setting_push_notifications') ?? true;
        _darkMode = prefs.getBool('setting_dark_mode') ?? true;
        _emailNotifications = prefs.getBool('setting_email_notifications') ?? true;
        _smsNotifications = prefs.getBool('setting_sms_notifications') ?? false;
        _selectedLanguage = prefs.getString('setting_language') ?? 'English';
        _selectedCurrency = prefs.getString('setting_currency') ?? 'USD';
      });
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefKey = 'setting_$key';
      
      if (value is bool) {
        await prefs.setBool(prefKey, value);
      } else if (value is String) {
        await prefs.setString(prefKey, value);
      }
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting saved'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications Section
                  _buildSectionHeader('Notifications'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.notifications,
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() => _pushNotifications = value);
                        _saveSetting('push_notifications', value);
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.email,
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() => _emailNotifications = value);
                        _saveSetting('email_notifications', value);
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.sms,
                      title: 'SMS Notifications',
                      subtitle: 'Receive notifications via SMS',
                      value: _smsNotifications,
                      onChanged: (value) {
                        setState(() => _smsNotifications = value);
                        _saveSetting('sms_notifications', value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Appearance Section
                  _buildSectionHeader('Appearance'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme',
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() => _darkMode = value);
                        _saveSetting('dark_mode', value);
                      },
                    ),
                    _buildLanguageTile(),
                    _buildCurrencyTile(),
                  ]),

                  const SizedBox(height: 24),

                  // App Information Section
                  _buildSectionHeader('App Information'),
                  _buildSettingsCard([
                    _buildInfoTile(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: '1.0.0',
                    ),
                    _buildActionTile(
                      icon: Icons.clear_all,
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space (~25 MB)',
                      onTap: _showClearCacheDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.system_update,
                      title: 'Check for Updates',
                      subtitle: 'Look for app updates',
                      onTap: _checkForUpdates,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Legal Section
                  _buildSectionHeader('Legal & Support'),
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: _showPrivacyPolicy,
                    ),
                    _buildActionTile(
                      icon: Icons.description,
                      title: 'Terms of Service',
                      subtitle: 'Read terms and conditions',
                      onTap: _showTermsOfService,
                    ),
                    _buildActionTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help or contact support',
                      onTap: _showHelpAndSupport,
                    ),
                    _buildActionTile(
                      icon: Icons.info,
                      title: 'About TechHub',
                      subtitle: 'Learn more about our app',
                      onTap: _showAboutApp,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Reset Section
                  _buildSectionHeader('Reset'),
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.refresh,
                      title: 'Reset Settings',
                      subtitle: 'Restore default settings',
                      onTap: _showResetSettingsDialog,
                      isDestructive: true,
                    ),
                  ]),

                  const SizedBox(height: 100), // Extra space for bottom navigation
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primary),
      title: const Text('Language', style: AppTextStyles.bodyLarge),
      subtitle: Text(_selectedLanguage, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: _showLanguageSelector,
    );
  }

  Widget _buildCurrencyTile() {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: AppColors.primary),
      title: const Text('Currency', style: AppTextStyles.bodyLarge),
      subtitle: Text(_selectedCurrency, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: _showCurrencySelector,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.red : null,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.red : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Language', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            ...[
              {'code': 'English', 'name': 'English', 'flag': '🇺🇸'},
              {'code': 'Spanish', 'name': 'Español', 'flag': '🇪🇸'},
              {'code': 'French', 'name': 'Français', 'flag': '🇫🇷'},
              {'code': 'German', 'name': 'Deutsch', 'flag': '🇩🇪'},
              {'code': 'Italian', 'name': 'Italiano', 'flag': '🇮🇹'},
              {'code': 'Portuguese', 'name': 'Português', 'flag': '🇵🇹'},
              {'code': 'Japanese', 'name': '日本語', 'flag': '🇯🇵'},
              {'code': 'Chinese', 'name': '中文', 'flag': '🇨🇳'},
            ].map((lang) => ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(lang['name']!, style: AppTextStyles.bodyLarge),
              trailing: _selectedLanguage == lang['code']
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = lang['code']!);
                _saveSetting('language', lang['code']!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Currency', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            ...[
              {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
              {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
              {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
              {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
              {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
              {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
            ].map((currency) => ListTile(
              leading: Text(currency['symbol']!, 
                style: const TextStyle(fontSize: 24, color: AppColors.primary)),
              title: Text(currency['name']!, style: AppTextStyles.bodyLarge),
              subtitle: Text(currency['code']!, style: AppTextStyles.bodySmall),
              trailing: _selectedCurrency == currency['code']
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedCurrency = currency['code']!);
                _saveSetting('currency', currency['code']!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cache', style: AppTextStyles.heading3),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
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
            onPressed: () {
              Navigator.pop(context);
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

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Settings', style: AppTextStyles.heading3),
        content: const Text(
          'This will restore all settings to their default values. This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Reset all settings to defaults
              final prefs = await SharedPreferences.getInstance();
              final settingsKeys = prefs.getKeys().where((key) => key.startsWith('setting_'));
              for (String key in settingsKeys) {
                await prefs.remove(key);
              }
              
              // Reload settings
              await _loadSettings();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Check for Updates', style: AppTextStyles.heading3),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Checking for updates...', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );

    // Simulate checking for updates
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Up to Date', style: AppTextStyles.heading3),
          content: const Text(
            'You are using the latest version of TechHub!',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _showPrivacyPolicy() {
    // Navigate to privacy policy or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Privacy Policy...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showTermsOfService() {
    // Navigate to terms or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Terms of Service...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showHelpAndSupport() {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Help & Support...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAboutApp() {
    // Navigate to about screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening About...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}