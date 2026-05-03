import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:emergency_response_app/repositories/post/post_repository.dart';

//Edit an existing post. Lets the author change text, add or remove
//images, and toggle urgency. Submitting calls
//[PostRepository.updatePost] and pops with `true` so the caller can
//refresh.
class EditPostPage extends StatefulWidget {
  final Post post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _content;
  final _picker = ImagePicker();

  // Existing image URLs the user has chosen to keep.
  late List<String> _keptImageUrls;
  // Newly-picked local files to upload on save.
  final List<File> _newImages = [];

  late bool _isUrgent;
  bool _loading = false;
  String? _error;

  late final PostRepository _repository;

  @override
  void initState() {
    super.initState();
    _content = TextEditingController(text: widget.post.content);
    _keptImageUrls = List<String>.from(widget.post.imageUrls);
    _isUrgent = widget.post.isUrgent;
    _repository = PostRepository(firestore: FirebaseFirestore.instance);
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
        _newImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _save() async {
    if (_content.text.trim().isEmpty) {
      setState(() => _error = 'Post content cannot be empty.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repository.updatePost(
        communityId: widget.post.communityId,
        postId: widget.post.postId,
        content: _content.text.trim(),
        isUrgent: _isUrgent,
        keptImageUrls: _keptImageUrls,
        newImages: _newImages,
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
    // Adjust colors based on dark mode for better visibility.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final urgentCardColor = _isUrgent
      ? isDarkMode
        ? Colors.red.shade700
        : Colors.red.shade50
      : null;

    final urgentTextColor = _isUrgent
      ? (isDarkMode ? Colors.black : Colors.black) : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
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

            // Existing images the user can remove individually.
            if (_keptImageUrls.isNotEmpty) ...[
              const Text(
                'Current images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _keptImageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _keptImageUrls[index],
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
                              setState(
                                () => _keptImageUrls.removeAt(index),
                              );
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

            // Newly picked, not-yet-uploaded images.
            if (_newImages.isNotEmpty) ...[
              const Text(
                'New images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _newImages[index],
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
                              setState(() => _newImages.removeAt(index));
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

            // Urgent toggle. Note: re-flagging an existing post as urgent
            // does NOT re-fire notifications — only fresh urgent posts do.
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
                activeColor: Colors.red,
                onChanged: (v) => setState(() => _isUrgent = v),
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: _isUrgent ? urgentTextColor : Colors.grey,
                      // color: _isUrgent ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mark as urgent',
                      style: TextStyle(fontWeight: FontWeight.bold, color: urgentTextColor),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Editing urgency will not send a new notification.',
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
