import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service for Reform Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: January 2026',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using Reform Wallet, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you may not access the service.',
            ),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the Reform Wallet application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
            ),
            _buildSection(
              '3. Disclaimer',
              'The materials on Reform Wallet are provided on an "as is" basis. Reform Wallet makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties.\n\n'
              'Specifically, the tax calculations provided by this app are estimates based on the Nigeria 2026 Tax Reform policy. They do not constitute professional financial or tax advice. Users should consult with a qualified tax professional for official tax filing.',
            ),
            _buildSection(
              '4. Limitations',
              'In no event shall Reform Wallet or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Reform Wallet.',
            ),
            _buildSection(
              '5. Accuracy of Materials',
              'The materials appearing on Reform Wallet could include technical, typographical, or photographic errors. Reform Wallet does not warrant that any of the materials on its app are accurate, complete, or current.',
            ),
            _buildSection(
              '6. Modifications',
              'Reform Wallet may revise these terms of service for its app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.',
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