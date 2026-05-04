import 'dart:convert';

import 'package:emergency_response_app/core/services/isar/isar_service.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

class PocketBaseBackupService {
  PocketBaseBackupService({
    this.baseUrl = 'http://10.42.0.1:8090',
  });

  final String baseUrl;

  String get _recordsUrl => '$baseUrl/api/collections/disaster_posts/records';

  Future<List<Post>> fetchBackupPosts() async {
    final uri = Uri.parse(
      '$_recordsUrl?sort=-createdAtClient&perPage=100',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch backup posts. '
            'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;

    return items
        .map((item) => _postFromPocketBaseJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Post> createBackupPost(Post post) async {
    final response = await http.post(
      Uri.parse(_recordsUrl),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(_postToPocketBaseJson(post)),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create backup post. '
            'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return _postFromPocketBaseJson(decoded);
  }

  Future<int> importBackupPostsToIsar() async {
    final backupPosts = await fetchBackupPosts();
    final isar = IsarService.isar;
    var importedCount = 0;

    await isar.writeTxn(() async {
      for (final backupPost in backupPosts) {
        final existing = await isar.posts
            .filter()
            .postIdEqualTo(backupPost.postId)
            .findFirst();

        if (existing == null ||
            backupPost.updatedAt.isAfter(existing.updatedAt)) {
          backupPost.isSynced = false;
          await isar.posts.put(backupPost);
          importedCount++;
        }
      }
    });

    return importedCount;
  }

  Post _postFromPocketBaseJson(Map<String, dynamic> json) {
    final post = Post(
      postId: (json['postId'] ?? json['id']) as String,
      communityId: (json['communityId'] ?? 'backup-demo-community') as String,
      authorId: (json['authorId'] ?? 'backup-demo-user') as String,
      authorName: (json['authorName'] ?? 'Backup Demo User') as String,
      content: (json['content'] ?? '') as String,
      createdAt: _parsePocketBaseDate(json['createdAtClient']),
      updatedAt: _parsePocketBaseDate(json['updatedAtClient']),
      isUrgent: (json['isUrgent'] ?? false) as bool,
      isSynced: false,
    );

    final imageUrls = json['imageUrls'];
    if (imageUrls is List) {
      post.imageUrls = imageUrls.map((url) => url.toString()).toList();
    } else {
      post.imageUrls = [];
    }

    return post;
  }

  Map<String, dynamic> _postToPocketBaseJson(Post post) {
    return {
      'postId': post.postId,
      'communityId': post.communityId,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'content': post.content,
      'imageUrls': post.imageUrls,
      'createdAtClient': post.createdAt.toUtc().toIso8601String(),
      'updatedAtClient': post.updatedAt.toUtc().toIso8601String(),
      'isUrgent': post.isUrgent,
    };
  }

  DateTime _parsePocketBaseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toLocal();
    }

    return DateTime.now();
  }
}