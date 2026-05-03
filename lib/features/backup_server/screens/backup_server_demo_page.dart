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

  Future<void> _createTestAlert() async {
    setState(() {
      _isCreatingPost = true;
    });

    try {
      await _backupService.createDisasterPost(
        title: 'Demo emergency alert',
        body: 'This alert was created from the Flutter app through DisasterNet.',
        urgent: true,
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
        onPressed: _isCreatingPost ? null : _createTestAlert,
        icon: _isCreatingPost
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.add_alert),
        label: Text(_isCreatingPost ? 'Creating...' : 'Create Test Alert'),
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