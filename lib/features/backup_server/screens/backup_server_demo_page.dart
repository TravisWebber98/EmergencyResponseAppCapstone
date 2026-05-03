import 'package:flutter/material.dart';

import 'package:emergency_response_app/core/services/pocketbase_backup_service.dart';

class BackupServerDemoPage extends StatefulWidget {
  const BackupServerDemoPage({super.key});

  @override
  State<BackupServerDemoPage> createState() => _BackupServerDemoPageState();
}

class _BackupServerDemoPageState extends State<BackupServerDemoPage> {
  final PocketBaseBackupService _backupService = PocketBaseBackupService();

  late Future<List<DisasterPost>> _postsFuture;
  bool _isCreatingPost = false;

  @override
  void initState() {
    super.initState();
    _postsFuture = _backupService.fetchDisasterPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _backupService.fetchDisasterPosts();
    });
  }

  Future<void> _showCreatePostDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool urgent = true;

    final result = await showDialog<({String title, String body, bool urgent})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Backup Alert'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Example: Road blocked',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        hintText: 'Example: Tree down on Main Street',
                      ),
                      maxLines: 3,
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
                    final title = titleController.text.trim();
                    final body = bodyController.text.trim();

                    if (title.isEmpty || body.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title and details are required.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      (
                      title: title,
                      body: body,
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

    titleController.dispose();
    bodyController.dispose();

    if (result == null) return;

    await _createDisasterPost(
      title: result.title,
      body: result.body,
      urgent: result.urgent,
    );
  }

  Future<void> _createDisasterPost({
    required String title,
    required String body,
    required bool urgent,
  }) async {
    setState(() {
      _isCreatingPost = true;
    });

    try {
      await _backupService.createDisasterPost(
        title: title,
        body: body,
        urgent: urgent,
      );

      await _refreshPosts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Created alert on backup server.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create alert: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isCreatingPost = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Server Demo'),
        actions: [
          IconButton(
            onPressed: _refreshPosts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreatingPost ? null : _showCreatePostDialog,
        icon: _isCreatingPost
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.add_alert),
        label: Text(_isCreatingPost ? 'Creating...' : 'Create Alert'),
      ),
      body: FutureBuilder<List<DisasterPost>>(
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
              child: Text('No disaster posts found on backup server.'),
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
                    backgroundColor: post.urgent ? Colors.red : Colors.blueGrey,
                    child: Icon(
                      post.urgent
                          ? Icons.warning_amber_rounded
                          : Icons.article,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(post.title),
                  subtitle: Text(post.body),
                  trailing: post.urgent
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