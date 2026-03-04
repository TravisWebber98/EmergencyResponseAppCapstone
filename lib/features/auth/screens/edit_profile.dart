import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class editProfilePage extends StatefulWidget {
  const editProfilePage({super.key});

  @override
  State<editProfilePage> createState() => _editProfilePageState();
}

class _editProfilePageState extends State<editProfilePage>{
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  // optional location settings:
  // final _city = TextEditingController();
  // final _state = TextEditingController();
  // final _country = TextEditingController();

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _loadingInitial = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _error = "Not logged in!";
      });
      return;
    }

    try {
      // form will be pre-filled so any undesired changes will stay.
      final doc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      _name.text = (data['display'] ?? user.displayName ?? '').toString();
      _phone.text = (data['phone'] ?? '').toString();
      _email.text = (data['email'] ?? user.email ?? '').toString();

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!mounted) return;
      setState(() => _loadingInitial = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = "Not logged in!";
      });
      return;
    }

    final newDisplay = _name.text.trim();
    final newPhone = _phone.text.trim();
    final newEmail = _email.text.trim();

    try {
      // can update email, but is supposed to send a verification email that needs to be
      // confirmed before changing email
      // otherwise original email still still need to be used for login
      if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      if (_newPassword.text.isNotEmpty || _confirmPassword.text.isNotEmpty) {
        if (_newPassword.text != _confirmPassword.text) {
          throw Exception("Passwords do not match");
        }
        if (_newPassword.text.length < 6) {
          throw Exception("Password must be at least 6 characters");
        }
        await user.updatePassword(_newPassword.text);
      }

      if (newDisplay.isNotEmpty && newDisplay != (user.displayName ?? '')) {
        await user.updateDisplayName(newDisplay);
      }

      final updates = <String, dynamic>{};

      if (newDisplay.isNotEmpty) updates['display'] = newDisplay;
      if (newPhone.isNotEmpty) updates['phone'] = newPhone;
      if (newEmail.isNotEmpty) updates['email'] = newEmail;
      updates['updatedAt'] = FieldValue.serverTimestamp();
      // if the user leaves a field clear, it shouldnt overwrite existing
      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(user.uid)
            .set(updates, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Profile Page')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 175.0)),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Display Name',
                  hintText: "Enter a new Display Name",
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter email',
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
                  labelText: 'Enter phone number',
                  hintText: "Enter valid phone number",
                ),
              ),
            ),

            // SPACE FOR LOCATION CHANGES, if needed

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _newPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter valid password',
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                controller: _confirmPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                  hintText: 'Confirm password',
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),  
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
                    onPressed: _loading ? null : _save,
                    child: Text(
                      'Save Changes',
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
                    onPressed: _loading ? null : () => Navigator.pop(context),
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