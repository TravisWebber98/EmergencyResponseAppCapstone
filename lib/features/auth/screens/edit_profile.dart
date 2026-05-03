import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/widgets/FormSection.dart';
import 'package:emergency_response_app/widgets/customTextField.dart';
import 'package:emergency_response_app/widgets/customButon.dart';
import 'package:emergency_response_app/widgets/customDropdown.dart';
import 'package:emergency_response_app/widgets/states_list.dart';
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
  final _city = TextEditingController();

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  // Selected state code/name from the dropdown. Mirrors signup.dart's
  // pattern of separating dropdown selection from a text controller.
  String? _selectedState;

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
      _city.text = (data['city'] ?? '').toString();
      // Only assign if the existing state value is in StatesList; otherwise
      // the dropdown asserts. Defaults to null which renders as "no selection".
      final existingState = (data['state'] ?? '').toString();
      if (existingState.isNotEmpty && StatesList.contains(existingState)) {
        _selectedState = existingState;
      }

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
    _city.dispose();
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
    final newCity = _city.text.trim();
    final newState = _selectedState;

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
      // Location: write whichever was actually entered. Same "blank means
      // don't overwrite" rule as the other fields.
      if (newCity.isNotEmpty) updates['city'] = newCity;
      if (newState != null && newState.isNotEmpty) updates['state'] = newState;
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

        body: FormSection(
            child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 175.0)),
                  CustomTextField(
                      hintText: "Enter a new Display Name",
                      label: "Display Name",
                      controller: _name
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                      hintText: "Enter valid email",
                      label: "Email",
                      controller: _email
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                      hintText: "Enter valid phone number",
                      label: "Phone Number",
                      controller: _phone
                  ),
                  const SizedBox(height: 16),

                  // Location: city as free text + state from the same
                  // dropdown used at signup so values stay consistent.
                  CustomTextField(
                    hintText: "City",
                    label: "City",
                    controller: _city,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdown(
                    label: 'State',
                    items: StatesList,
                    value: _selectedState,
                    onChanged: (value) {
                      setState(() => _selectedState = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hintText: "Enter valid password",
                    label: "New Password",
                    controller: _newPassword,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hintText: "Confirm password",
                    label: "Confirm Password",
                    controller: _confirmPassword,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: Custombuton(
                      text: 'Save Changes',
                      onPressed: _save,
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Custombuton(
                      text: 'Cancel',
                      secondaryStyle: true,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),

                  ),
                ]
            ))
    );
  }
}