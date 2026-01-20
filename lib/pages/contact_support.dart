import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupport extends StatefulWidget {
  const ContactSupport({super.key});

  @override
  State<ContactSupport> createState() => _ContactSupportState();
} 

class _ContactSupportState extends State<ContactSupport> {

  final String whatsappUrl = 'https://wa.me/2348033338778';
  final String xUrl = 'https://x.com/kvngayomide5';
  final String linkedinUrl = 'https://linkedin.com/in/ayomide-aregbe';

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with us'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 200, 16.0, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI assistant coming soon... \n'
              'Contact us through the links below'),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      _buildSocialButton(
                      Image.asset('assets/socials/whatsapp.png'),
                      'Whatsapp',
                      Color(0xFF25D366),
                      () {
                        _launchURL(whatsappUrl);
                      },
                      ),
                    SizedBox(width: 8),
                    _buildSocialButton(
                      Image.asset('assets/socials/x.png'),
                      'X',
                      Color.fromARGB(255, 4, 5, 4),
                      () {
                        _launchURL(xUrl);
                      },
                      ),
                    SizedBox(width: 8),
                    _buildSocialButton(
                      Image.asset('assets/socials/linkedin.png'),
                      'LinkedIn',
                      Color.fromARGB(255, 22, 91, 147),
                      () {
                        _launchURL(linkedinUrl);
                      },
                      ),
                    
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(dynamic icon, String label, Color color, VoidCallback url) {
    return GestureDetector(
      onTap: url,
      child: Container(
        width: 80,
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha:0.3),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 6,),
            icon,
            SizedBox(height: 18),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}