import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Widgets
import 'package:emergency_response_app/widgets/customDropdown.dart';
import 'package:emergency_response_app/widgets/states_list.dart';
import 'package:emergency_response_app/widgets/customButon.dart';
import 'package:emergency_response_app/widgets/customTextField.dart';
// import '../auth_service.dart';
// import '../profile_service.dart';

// import 'app_nav.dart';
import 'login.dart';

class registerPage extends StatefulWidget {
  const registerPage({super.key});
  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage>{
  final _formKey = GlobalKey<FormState>();

  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
 
  final _businessName = TextEditingController();

  String? selectedState;
  String? error;
  bool loading = false;

  Future<void> _register() async {
    setState(() {
      error = null;
      loading = true;
    });

    try {
      if (_password.text != _confirmPassword.text) {
        throw Exception ("Passwords do not match");
      }

      final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      final uid = cred.user!.uid;
      
      await FirebaseFirestore.instance.collection('accounts').doc(uid).set({
        'accountType': 'user',
        'banUntil': null, //timestamp
        'businessName:': _businessName.text.trim(),
        'city': _city.text.trim(),
        'country': 'United States', 
        'createdAt': FieldValue.serverTimestamp(), //timestamp

        'display': _displayName.text.trim(), 
        'email': _email.text.trim(),
        'isBanned': false,
        'phone': _phone.text.trim(),
        'state': selectedState,
        'updatedAt': FieldValue.serverTimestamp(), //timestamp, 
        'verified': false,
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false);
    } catch(e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) 
        setState (() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Register Page')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Display Name',
                  hintText: 'Display Name', 
                  controller: _displayName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email',
                  hintText: 'Email',
                  controller: _email,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Phone Number',
                  hintText: 'Phone Number',
                  controller: _phone,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Business Name',
                  hintText: 'Leave blank if not applicable',
                  controller: _businessName,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'City',
                  hintText: 'City',
                  controller: _city,
                ),
                const SizedBox(height: 16),
                
                CustomDropdown(
                  label: 'State', 
                  items: StatesList, 
                  value: selectedState, 
                  onChanged: (value){
                    setState(() {
                      selectedState = value;
                    });
                  }
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Password',
                  hintText: 'Password', 
                  controller: _password,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm Password', 
                  controller: _confirmPassword,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: Custombuton(
                    text: 'Sign Up',
                    onPressed: _register
                  )
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Custombuton(
                    text: 'Cancel', 
                    secondaryStyle: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const loginPage()),
                      );
                    },
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}