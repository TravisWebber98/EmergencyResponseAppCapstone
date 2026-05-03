import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emergency_response_app/repositories/post/post_repository.dart';
import 'package:emergency_response_app/core/services/location/location_service.dart';

class CreatePostPage extends StatefulWidget {
  final String communityId;

  const CreatePostPage({super.key, required this.communityId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _content = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _loading = false;
  bool _isUrgent = false;
  String? _error;

  // Location attachment. All three are null when no location is attached;
  // they're set together when the user resolves their current location,
  // and cleared together when they tap the X.
  double? _latitude;
  double? _longitude;
  String? _locationLabel;
  bool _resolvingLocation = false;

  late final PostRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = PostRepository(
      firestore: FirebaseFirestore.instance,
    );
  }

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  // Resolve the user's current location and stash it on this post draft.
  // On failure, surface the LocationException message in a SnackBar so
  // the user can act on it (turn on services, change settings, etc.).
  Future<void> _attachCurrentLocation() async {
    setState(() => _resolvingLocation = true);
    try {
      final result = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _locationLabel = result.label.isNotEmpty
            ? result.label
            : '${result.latitude.toStringAsFixed(4)}, '
                '${result.longitude.toStringAsFixed(4)}';
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    } finally {
      if (mounted) setState(() => _resolvingLocation = false);
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _locationLabel = null;
    });
  }

  // Either the "Use My Current Location" button or, once a location is
  // attached, an info row showing the resolved label with a remove button.
  Widget _buildLocationSection() {
    final hasLocation = _latitude != null && _longitude != null;
    if (!hasLocation) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _resolvingLocation ? null : _attachCurrentLocation,
          icon: _resolvingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(_resolvingLocation
              ? 'Getting location…'
              : 'Use My Current Location'),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: const Text(
          'Location attached',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _locationLabel ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Remove location',
          onPressed: _clearLocation,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_content.text.trim().isEmpty) {
      setState(() => _error = 'Post content cannot be empty.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in.');

      // Get display name from Firestore account
      final accountDoc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .get();
      final authorName =
          accountDoc.data()?['display'] ?? user.email ?? 'Unknown';

      await _repository.createPost(
        communityId: widget.communityId,
        authorId: user.uid,
        authorName: authorName,
        content: _content.text.trim(),
        images: _selectedImages,
        isUrgent: _isUrgent,
        latitude: _latitude,
        longitude: _longitude,
        locationLabel: _locationLabel,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust colors based on theme and urgency
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color? urgentCardColor = _isUrgent
      ? (isDarkMode
        ? Colors.red.shade700
        : Colors.red.shade50)
      : null;

    final Color urgentTextColor = _isUrgent
      ? (isDarkMode ? Colors.white : Colors.black) : Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Post',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _content,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "What's on your mind?",
                labelText: 'Post Content',
              ),
            ),
            const SizedBox(height: 16),

            // Selected images preview
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedImages.removeAt(index));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Add Images'),
            ),

            const SizedBox(height: 16),

            // Location attachment (optional, opt-in). Hidden by default;
            // when the user taps the button, we resolve their current
            // GPS location and reverse-geocode it to a friendly label.
            // Once attached, shows the label with an X to remove.
            _buildLocationSection(),

            const SizedBox(height: 16),

            //Urgent flag. When on, every other community member receives
            //an in-app notification when this post is created.
            Card(
              color: urgentCardColor,
              // color: _isUrgent ? Colors.red.shade50 : null,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _isUrgent ? Colors.red : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                value: _isUrgent,
                activeThumbColor: Colors.red,
                onChanged: (v) => setState(() => _isUrgent = v),
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: _isUrgent ? urgentTextColor : const Color.fromARGB(255, 135, 133, 133),
                      // color: _isUrgent ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mark as urgent',
                      style: TextStyle(fontWeight: FontWeight.bold, color: urgentTextColor),
                    ),
                  ],
                ),
                subtitle:  Text(
                  'All community members will be notified.',
                  style: TextStyle(fontSize: 12, color: urgentTextColor),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}