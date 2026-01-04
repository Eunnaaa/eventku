import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class GuestLandingScreen extends StatelessWidget {
  const GuestLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              /// LOGO
              Image.asset(
                'assets/images/logo1.png',
                height: 90,
              ),

              const SizedBox(height: 30),

              /// HEADLINE
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: 'DISCOVER '),
                    TextSpan(
                      text: 'EDUCATION ',
                      style: TextStyle(color: Color(0xFFFF914D)),
                    ),
                    TextSpan(text: 'EVENTS WITH EASE'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// SUBTITLE
              const Text(
                'Temukan seminar, workshop, dan event pendidikan\nuntuk mengembangkan masa depanmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const Spacer(),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF914D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF914D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color(0xFFFF914D),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
