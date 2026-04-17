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
              child:  CustomTextField(
                controller: _identifier,
                label: 'Email',
                hintText: 'Enter valid email',
              ),

              



              // child: TextField(
              //   controller: _identifier,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Email',
              //     hintText: "Enter valid email",
              //   ),
              // ),

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


              // child: TextField(
              //   controller: _password,
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Password',
              //     hintText: 'Enter valid password',
              //   ),
              // ),

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
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}