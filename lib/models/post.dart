import 'package:isar_community/isar.dart';
// Hide cloud_firestore's `Query` because both libraries export a class with
// that name. The generated post.g.dart references Isar's Query.epsilon for
// the new latitude/longitude range queries, and without this hide the
// analyzer can't disambiguate. We only need Timestamp from cloud_firestore.
import 'package:cloud_firestore/cloud_firestore.dart' hide Query;

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
    this.latitude,
    this.longitude,
    this.locationLabel,
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

  //Optional location of the incident the post is about. All three are
  //null together — either we have a location attachment or we don't.
  //locationLabel is a human-readable string like "Houston, TX"; coords
  //are kept too so a future map view doesn't have to re-geocode.
  double? latitude;
  double? longitude;
  String? locationLabel;

  bool isSynced;

  //Convenience: true when the post has a usable location attachment.
  bool get hasLocation => latitude != null && longitude != null;

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
      // Older docs may not have these fields — all three default to null.
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationLabel: json['locationLabel'] as String?,
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
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
    };
  }
}