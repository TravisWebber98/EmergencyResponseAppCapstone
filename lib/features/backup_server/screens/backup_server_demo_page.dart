import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:emergency_response_app/core/services/pocketbase_backup_service.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:emergency_response_app/repositories/post/post_repository.dart';

class BackupServerDemoPage extends StatefulWidget {
  const BackupServerDemoPage({
    super.key,
    this.defaultCommunityId = 'backup-demo-community',
  });

  final String defaultCommunityId;

  @override
  State<BackupServerDemoPage> createState() => _BackupServerDemoPageState();
}

class _BackupServerDemoPageState extends State<BackupServerDemoPage> {
  final PocketBaseBackupService _backupService = PocketBaseBackupService();
  final PostRepository _postRepository = PostRepository(
    firestore: FirebaseFirestore.instance,
  );

  late Future<List<Post>> _postsFuture;
  bool _isCreatingPost = false;
  bool _isImportingToIsar = false;
  bool _isSyncingToFirestore = false;

  @override
  void initState() {
    super.initState();
    _postsFuture = _backupService.fetchBackupPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _backupService.fetchBackupPosts();
    });
  }

  Future<void> _showCreatePostDialog() async {
    final communityIdController = TextEditingController(
      text: widget.defaultCommunityId,
    );
    final authorNameController = TextEditingController(
      text: 'Backup Demo User',
    );
    final contentController = TextEditingController();
    bool urgent = true;

    final result = await showDialog<
        ({
        String communityId,
        String authorName,
        String content,
        bool urgent,
        })>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Backup Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: communityIdController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Community ID',
                        helperText: 'Using the current community board',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Author Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Post content',
                        hintText: 'Example: Road blocked near Main Street',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Urgent'),
                      value: urgent,
                      onChanged: (value) {
                        setDialogState(() {
                          urgent = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final communityId = communityIdController.text.trim();
                    final authorName = authorNameController.text.trim();
                    final content = contentController.text.trim();

                    if (communityId.isEmpty ||
                        authorName.isEmpty ||
                        content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Community ID, author name, and content are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      (
                      communityId: communityId,
                      authorName: authorName,
                      content: content,
                      urgent: urgent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    await _createBackupPost(
      communityId: result.communityId,
      authorName: result.authorName,
      content: result.content,
      isUrgent: result.urgent,
    );
  }

  Future<void> _createBackupPost({
    required String communityId,
    required String authorName,
    required String content,
    required bool isUrgent,
  }) async {
    setState(() {
      _isCreatingPost = true;
    });

    try {
      final now = DateTime.now();

      final post = Post(
        postId: 'pb_${now.microsecondsSinceEpoch}',
        communityId: communityId,
        authorId: 'backup-demo-user',
        authorName: authorName,
        content: content,
        createdAt: now,
        updatedAt: now,
        isUrgent: isUrgent,
        isSynced: false,
      );
      post.imageUrls = [];

      await _backupService.createBackupPost(post);
      await _refreshPosts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Created post on PocketBase backup server.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create backup post: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isCreatingPost = false;
      });
    }
  }

  Future<void> _importPocketBasePostsToIsar() async {
    setState(() {
      _isImportingToIsar = true;
    });

    try {
      final importedCount = await _backupService.importBackupPostsToIsar();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $importedCount post(s) into Isar.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import posts into Isar: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isImportingToIsar = false;
      });
    }
  }

  Future<void> _syncIsarPostsToFirestore() async {
    setState(() {
      _isSyncingToFirestore = true;
    });

    try {
      await _postRepository.syncUnsyncedPosts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synced unsynced Isar posts to Firestore.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync Isar posts to Firestore: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSyncingToFirestore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy =
        _isCreatingPost || _isImportingToIsar || _isSyncingToFirestore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Server Demo'),
        actions: [
          IconButton(
            tooltip: 'Refresh PocketBase posts',
            onPressed: _refreshPosts,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Import PocketBase posts into Isar',
            onPressed: _isImportingToIsar ? null : _importPocketBasePostsToIsar,
            icon: _isImportingToIsar
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.download),
          ),
          IconButton(
            tooltip: 'Sync Isar posts to Firestore',
            onPressed:
            _isSyncingToFirestore ? null : _syncIsarPostsToFirestore,
            icon: _isSyncingToFirestore
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.cloud_upload),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isBusy ? null : _showCreatePostDialog,
        icon: _isCreatingPost
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.add_alert),
        label: Text(_isCreatingPost ? 'Creating...' : 'Create Backup Post'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Could not connect to backup server:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text('No backup posts found on PocketBase.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = posts[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    post.isUrgent ? Colors.red : Colors.blueGrey,
                    child: Icon(
                      post.isUrgent
                          ? Icons.warning_amber_rounded
                          : Icons.article,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(post.authorName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content),
                      const SizedBox(height: 4),
                      Text(
                        'Community: ${post.communityId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: post.isUrgent
                      ? const Chip(
                    label: Text('URGENT'),
                    backgroundColor: Color(0xFFFFCDD2),
                  )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}