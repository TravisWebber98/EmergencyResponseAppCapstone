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