import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/repositories/community/firebase_community_repository.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _rules = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  // final _country = TextEditingController();

  bool _loading = false;
  String? _error;

  late final FirebaseCommunityRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseCommunityRepository(
      firestore: FirebaseFirestore.instance,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _rules.dispose();
    _city.dispose();
    _state.dispose();
    // _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Basic validation
    if (_name.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _city.text.trim().isEmpty ||
        _state.text.trim().isEmpty 
        // ||_country.text.trim().isEmpty
      ) {
      setState(() => _error = 'Please fill out all required fields.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in.');

      // Use Firestore auto-generated ID as the communityId
      final docRef = FirebaseFirestore.instance.collection('communities').doc();
      final now = DateTime.now();

      final community = Community(
        communityId: docRef.id,
        name: _name.text.trim(),
        description: _description.text.trim(),
        rules: _rules.text.trim().isEmpty ? null : _rules.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        // country: _country.text.trim(),
        country: 'United States',
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addCommunity(community);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community created successfully!')),
      );
      Navigator.pop(context, true); // return true so CommPage can refresh
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
        title: const Text('Create Community'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Community Name *',
                hintText: 'e.g. Bryan Disaster Relief',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description *',
                hintText: 'What is this community about?',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _rules,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Rules (optional)',
                hintText: 'Community guidelines...',
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _city,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'City *',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _state,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'State *',
              ),
            ),
            const SizedBox(height: 12),

            // TextField(
            //   controller: _country,
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'Country *',
            //   ),
            // ),
            // const SizedBox(height: 24),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Create Community',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}