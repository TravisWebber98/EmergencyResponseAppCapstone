import 'package:isar_community/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'post.g.dart';

@Collection()
class Post {
  Post({
    required this.postId,
    required this.communityId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isUrgent = false,
    this.isSynced = false,
  });

  Id isarId = Isar.autoIncrement;

  String postId;
  String communityId;
  String authorId;
  String authorName;
  String content;
  String imageUrlsRaw = '';

  List<String> get imageUrls =>
      imageUrlsRaw.isEmpty ? [] : imageUrlsRaw.split(',');

  set imageUrls(List<String> urls) => imageUrlsRaw = urls.join(',');

  DateTime createdAt;
  DateTime updatedAt;

  // Whether this post was flagged urgent at the time it was posted/edited.
  // Drives the red badge + border in the feed and the notification fan-out.
  bool isUrgent;

  bool isSynced;

  factory Post.fromJson(Map<String, dynamic> json) {
    final post = Post(
      postId: json['postId'] as String,
      communityId: json['communityId'] as String,
      authorId: json['authorId'] as String,
      authorName: (json['authorName'] ?? 'Unknown') as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : (json['updatedAt'] as Timestamp).toDate(),
      isUrgent: (json['isUrgent'] ?? false) as bool,
      isSynced: true,
    );
    post.imageUrls = List<String>.from(json['imageUrls'] ?? []);
    return post;
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'communityId': communityId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isUrgent': isUrgent,
    };
  }
}