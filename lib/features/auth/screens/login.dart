import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}
class _loginPageState extends State<loginPage>{
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  String? error;
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
      error = null;
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
    }catch(e){
      setState(() => error = e.toString());
    } finally{
      if (mounted) setState(() => loading = false);
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
            const Padding(padding: EdgeInsets.only(top: 275.0)),

            // username
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: _identifier,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email or Username',
                  hintText: "Enter valid email/username",
                ),
              ),
            ),

            // password
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter valid password',
                ),
              ),
            ),

            // login button
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
                    onPressed: loading ? null : _login,
                    child: Text(
                      loading ? 'Logging in...' : 'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),

                  ),
                ),
              ),
            ),

            // register button
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
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}