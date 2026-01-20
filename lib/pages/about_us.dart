import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: const AssetImage('assets/images/ayomide.jpg'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ayomide Aregbe',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Software Engineer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),


            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'I am a passionate Software Engineer with a strong background in mobile application development using Flutter. '
                'I specialize in building user-centric solutions that solve real-world problems. '
                'With a keen eye for detail and a drive for innovation, I aim to create digital experiences that make life easier for Nigerians.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The Story Behind Reform Wallet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The inspiration for this app was born out of the confusion surrounding the Nigeria 2026 Tax Reform. '
              'I realized that many people, including myself, found it difficult to calculate their exact tax liability under the new progressive brackets.\n\n'
              'I wanted to build a solution that not only simplifies these calculations but also helps Nigerians track their daily income and expenses. '
              'Financial transparency is key to financial freedom, and my goal is to provide a tool that empowers you to make informed decisions about your money.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 20),
            
            // Signature
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- Ayomide',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}