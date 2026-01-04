import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullName = TextEditingController();
  final country = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data()!;
    fullName.text = data['fullName'] ?? '';
    country.text = data['country'] ?? '';
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'fullName': fullName.text.trim(),
        'country': country.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// FULL NAME
              TextFormField(
                controller: fullName,
                decoration: inputStyle('Full Name'),
                validator: (v) =>
                v!.isEmpty ? 'Full name required' : null,
              ),

              const SizedBox(height: 16),

              /// COUNTRY
              TextFormField(
                controller: country,
                decoration: inputStyle('Country'),
                validator: (v) =>
                v!.isEmpty ? 'Country required' : null,
              ),

              const Spacer(),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF914D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : saveProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
