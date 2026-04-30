import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//widgets
import 'package:emergency_response_app/widgets/customTextField.dart';
import 'package:emergency_response_app/widgets/customButon.dart';


class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}
//All possible error Messages from firebase auth
String _authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-credential.':
      return 'Email or password is incorrect.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    default:
      return 'Login failed. Please try again.';
  }
}
String _firestoreErrorMessage(String code) {
  switch (code) {
    case 'permission-denied':
      return 'invalid-credentials.';
    default:
      return 'Database error. Please try again.';
  }
}

class _loginPageState extends State<loginPage>{
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  String? errorMessage;
  bool loading = false;

  @override
  void dispose(){
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final id = _identifier.text.trim();
      String email = id;

      if(!id.contains('@')){
        final snap = await FirebaseFirestore
            .instance.collection('usernames').doc(id.toLowerCase()).get();
        if (!snap.exists) throw Exception("Username not found");
        email = snap['email'];
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: _password.text);
      if(!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false);
    }on FirebaseAuthException catch (e){

      setState(() {
        errorMessage = _authErrorMessage(e.code);
      });
    } on FirebaseException catch (e) {
      setState(() {
        errorMessage = _firestoreErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Login Page')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 125.0)),
            Image.asset('assets/logo.png', height: 150),
            // username
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child:  CustomTextField(
                controller: _identifier,
                label: 'Email',
                hintText: 'Enter valid email',
              ),
            ),

            // password
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: CustomTextField(
                controller: _password,
                label: 'Password',
                hintText: "Enter valid password",
                isPassword: true,
              ),
            ),
            // error message
            if (errorMessage != null)
              Padding(padding: const EdgeInsets.only(top: 10.0),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
              ),
            const SizedBox(height: 16),
            // login button
            SizedBox(
              width: double.infinity,
              child: Custombuton(
                text: 'Login',
                onPressed: _login,
              ),


            ),
            const SizedBox(height: 16),
            // register button
            SizedBox(
              width: double.infinity,

              child: Custombuton(
                  text: 'Register',
                  secondaryStyle: true,
                  onPressed: () => Navigator.pushNamed(context, '/register')
              ),




            ),
          ],
        ),
      ),
    );
  }
}