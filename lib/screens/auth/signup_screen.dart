import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final country = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool isObscure = true;
  bool isConfirmObscure = true;
  bool isLoading = false;

  Future<void> register() async {
    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      /// 🔐 SIMPAN USER KE FIRESTORE (ROLE FIXED USER)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': fullName.text.trim(),
        'email': email.text.trim(),
        'country': country.text.trim(),
        'role': 'user', // ✅ FIXED
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint('SIGNUP ERROR: ${e.code}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi gagal')),
      );
    } catch (e) {
      debugPrint('SIGNUP UNKNOWN ERROR: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration inputStyle({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// BACK
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              /// LOGO
              Image.asset('assets/images/logo1.png', height: 80),

              const SizedBox(height: 24),

              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'Create your account to explore education events.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// FULL NAME
              TextField(
                controller: fullName,
                decoration: inputStyle(
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 14),

              /// EMAIL
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: inputStyle(
                  hint: 'abc@email.com',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 14),

              /// COUNTRY
              TextField(
                controller: country,
                decoration: inputStyle(
                  hint: 'Country',
                  icon: Icons.public,
                ),
              ),

              const SizedBox(height: 14),

              /// PASSWORD
              TextField(
                controller: password,
                obscureText: isObscure,
                decoration: inputStyle(
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

              const SizedBox(height: 14),

              /// CONFIRM PASSWORD
              TextField(
                controller: confirmPassword,
                obscureText: isConfirmObscure,
                decoration: inputStyle(
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      isConfirmObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(
                              () => isConfirmObscure = !isConfirmObscure);
                    },
                  ),
                ),
              ),

              const Spacer(),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF914D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
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
}
