import 'package:flutter/material.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'By using EventKu, you agree to comply with all applicable laws '
                  'and regulations and not misuse the platform.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 24),

            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your personal information such as name and email will be stored '
                  'securely and used only for application functionality.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 24),

            Text(
              'Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Contact us at support@eventku.app if you have any questions.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
