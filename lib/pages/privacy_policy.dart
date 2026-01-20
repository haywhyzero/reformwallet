import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for Reform Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: January 2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            _buildSection(
              '1. Introduction',
              'Welcome to Reform Wallet. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights.',
            ),
            _buildSection(
              '2. Data We Collect',
              'Reform Wallet is designed as a local-first application. We collect and store the following data locally on your device:\n\n'
              '• Financial Data: Income and expense records, transaction categories, and amounts.\n'
              '• Usage Data: Preferences such as dark mode settings and notification reminders.\n\n'
              'We do not transmit this data to external servers. All data remains strictly on your device.',
            ),
            _buildSection(
              '3. How We Use Your Data',
              'We use your data solely to:\n'
              '• Provide expense tracking and budget management features.\n'
              '• Calculate estimated tax liabilities based on the 2026 Tax Reform policy.\n'
              '• Send local reminders for income or bill payments.',
            ),
            _buildSection(
              '4. Data Security',
              'Since your data is stored locally on your device, the security of your data relies on the security of your device. We recommend keeping your device secure with a password or biometric lock.',
            ),
            _buildSection(
              '5. Your Legal Rights',
              'You have the right to access, correct, or delete your personal data. You can delete all your data stored within the app via the Settings menu using the "Delete Account" or "Delete Data" option.',
            ),
            _buildSection(
              '6. Contact Us',
              'If you have any questions about this privacy policy, please contact us via the support section in the app.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}