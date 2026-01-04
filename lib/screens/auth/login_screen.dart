import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  Future<void> login() async {
    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // ✅ WAJIB: TUTUP LOGIN SCREEN
      if (mounted) {
        Navigator.of(context).pop();
      }

    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal';

      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// LOGO
              Image.asset(
                'assets/images/logo1.png',
                height: 80,
              ),

              const SizedBox(height: 24),

              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Login to explore our events',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// EMAIL
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _input(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              TextField(
                controller: password,
                obscureText: isObscure,
                decoration: _input(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      isObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => isObscure = !isObscure);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    if (email.text.isNotEmpty) {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(
                        email: email.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reset email sent'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFFFF914D)),
                  ),
                ),
              ),

              const Spacer(),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF914D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register here',
                      style: TextStyle(
                        color: Color(0xFFFF914D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
