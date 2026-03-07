import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/community.dart';
import '/providers/community_provider.dart';

class CreateCommunityPage extends ConsumerStatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  ConsumerState<CreateCommunityPage> createState() =>
      _CreateCommunityPageState();
}

class _CreateCommunityPageState extends ConsumerState<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveCommunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final communityRepo = ref.read(communityRepositoryProvider);

    final newCommunity = Community(
      communityId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await communityRepo.addCommunity(newCommunity);

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop(); // Return to community list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Community Name'),
                validator: (value) =>
                value!.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCommunity,
                child: _isSaving
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}