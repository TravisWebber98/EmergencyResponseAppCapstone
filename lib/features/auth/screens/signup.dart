import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _businessName = TextEditingController();

  String? error;
  bool loading = false;
  
  // @override
  // void dispose(){
  //   _email.dispose();
  //   _password.dispose();
  //   super.dispose();
  // }

  Future<void> _register() async {
    setState(() {
      error = null;
      loading = true;
    });

    try {
      if (_password.text != _confirmPassword.text) {
        throw Exception ("Passwords do not match");
      }

      // for signing up with username would create a seperate collection

      // final username = _username.text.trim().toLowerCase();
      // final usernameDoc = FirebaseFirestore
      //   .instance
      //   .collection('usernames')
      //   .doc(username);

      // if ((await usernameDoc.get()).exists) {
      //   throw Exception("Username already exists.");
      // }

      final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text);

      final uid = cred.user!.uid;
      
      
      await FirebaseFirestore.instance.collection('accounts').doc(uid).set({
        'accountType': 'user',
        'banUntil': null, //timestamp
        'businessName:': _businessName.text.trim(),
        'city': _city.text.trim(),
        'country': _country.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), //timestamp

        'display': _displayName.text.trim(), 
        'email': _email.text.trim(),
        'isBanned': false,
        'phone': _phone.text.trim(),
        'state': _state.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(), //timestamp, 
        'verified': false,
      });

      // for also setting up sign up with username:

      // await usernameDoc.set({
      //   'uid': uid,
      //   'email': _email.text.trim(),
      // });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false);
    } catch(e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState (() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Register Page')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 15.0)),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _displayName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Display Name',
                  hintText: "Enter a display name",
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Email',
                  hintText: "Enter valid email",
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Phone Number',
                  hintText: "Enter valid phone number",
                ),
              ),
            ),

            //businessName
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _businessName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Business Name',
                  hintText: "Leave empty if not any",
                ),
              ),
            ),

            // location add-ons textfields:
            // city
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _city,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'City',
                  hintText: "Enter your city",
                ),
              ),
            ),

            // state
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _state,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'State',
                  hintText: "Enter your state",
                ),
              ),
            ),

            // country
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _country,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Country',
                  hintText: "Enter your Country",
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter a valid password',
                ),
              ),
            ),


            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _confirmPassword,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                  hintText: 'Confirm Password',
                ),
              ),
            ),

            SizedBox(
              height: 65,
              width: 360,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed: 
                      loading ? null : _register,
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 65,
              width: 360,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const loginPage()),
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}