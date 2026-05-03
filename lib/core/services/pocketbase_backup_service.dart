import 'dart:convert';

import 'package:http/http.dart' as http;

class DisasterPost {
  DisasterPost({
    required this.id,
    required this.title,
    required this.body,
    required this.urgent,
    this.communityId,
    this.authorId,
    this.createdByDeviceId,
  });

  final String id;
  final String title;
  final String body;
  final bool urgent;
  final String? communityId;
  final String? authorId;
  final String? createdByDeviceId;

  factory DisasterPost.fromJson(Map<String, dynamic> json) {
    return DisasterPost(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      urgent: (json['urgent'] ?? false) as bool,
      communityId: json['communityId'] as String?,
      authorId: json['authorId'] as String?,
      createdByDeviceId: json['createdByDeviceId'] as String?,
    );
  }
}

class PocketBaseBackupService {
  PocketBaseBackupService({
    this.baseUrl = 'http://10.42.0.1:8090',
  });

  final String baseUrl;

  Future<List<DisasterPost>> fetchDisasterPosts() async {
    final uri = Uri.parse(
      '$baseUrl/api/collections/disaster_posts/records',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch disaster posts. '
            'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;

    return items
        .map((item) => DisasterPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}