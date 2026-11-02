import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

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

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    country.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = fullName.text.trim();
    final mail = email.text.trim();
    final ctry = country.text.trim();
    final pass = password.text.trim();
    final confirmPass = confirmPassword.text.trim();

    if (name.isEmpty || mail.isEmpty || ctry.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Semua field wajib diisi'),
        ),
      );
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Kata sandi minimal 6 karakter'),
        ),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Konfirmasi kata sandi tidak cocok'),
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail,
        password: pass,
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': name,
          'email': mail,
          'country': ctry,
          'role': 'user',
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal';

      if (e.code == 'email-already-in-use') {
        message = 'Email ini sudah terdaftar. Silakan login.';
      } else if (e.code == 'weak-password') {
        message = 'Kata sandi terlalu lemah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            content: Text(message),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            content: Text('Terjadi kesalahan: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppTheme.textDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daftar untuk menikmati akses ribuan event dan workshop menarik.',
                style: TextStyle(
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              /// FULL NAME
              _inputLabel('Nama Lengkap', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: fullName,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: _input(hint: 'John Doe', icon: Icons.person_outline_rounded, isDark: isDark),
              ),

              const SizedBox(height: 16),

              /// EMAIL
              _inputLabel('Alamat Email', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: _input(hint: 'nama@email.com', icon: Icons.email_outlined, isDark: isDark),
              ),

              const SizedBox(height: 16),

              /// COUNTRY
              _inputLabel('Kota / Asal Domisili', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: country,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: _input(hint: 'Jakarta, Indonesia', icon: Icons.location_city_rounded, isDark: isDark),
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              _inputLabel('Kata Sandi (min. 6 karakter)', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: password,
                obscureText: isObscure,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: _input(
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  suffix: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () => setState(() => isObscure = !isObscure),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
              _inputLabel('Ulangi Kata Sandi', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: confirmPassword,
                obscureText: isConfirmObscure,
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: _input(
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  suffix: IconButton(
                    icon: Icon(
                      isConfirmObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () => setState(() => isConfirmObscure = !isConfirmObscure),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              /// ALREADY HAVE ACCOUNT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white70 : AppTheme.textDark,
      ),
    );
  }

  InputDecoration _input({
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppTheme.textMuted(isDark),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
      ),
    );
  }
}
