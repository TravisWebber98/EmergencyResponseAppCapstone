import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar_community/isar.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:emergency_response_app/core/services/isar/isar_service.dart';
import 'package:emergency_response_app/core/services/cloudinary_service.dart';

class PostRepository {
  final FirebaseFirestore firestore;

  PostRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> _postsRef(String communityId) =>
      firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts');

  Future<void> createPost({
    required String communityId,
    required String authorId,
    required String authorName,
    required String content,
    List<File> images = const [],
  }) async {
    final isar = IsarService.isar;
    final now = DateTime.now();
    final docRef = _postsRef(communityId).doc();

    //Save to Isar immediately so it works offline
    final post = Post(
      postId: docRef.id,
      communityId: communityId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      //imageUrls: [],
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    post.imageUrls = []; //imageUrls is a getter/setter instead of a direct field, can't pass it in the constructor

    await isar.writeTxn(() async {
      await isar.posts.put(post);
    });

    // Sync to Firestore
    try {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await CloudinaryService.uploadImages(images);
      }

      await docRef.set({
        'postId': docRef.id,
        'communityId': communityId,
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Isar with URLs and mark synced
      await isar.writeTxn(() async {
        post.imageUrls = imageUrls;
        post.isSynced = true;
        await isar.posts.put(post);
      });
    } catch (e) {
      print('Firestore sync failed, will retry: $e');
    }
  }

  Future<List<Post>> getPosts(String communityId) async {
    final isar = IsarService.isar;

    try {
      final snapshot = await _postsRef(communityId)
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();

      // Cache to Isar
      await isar.writeTxn(() async {
        await isar.posts.putAll(posts);
      });

      return posts;
    } catch (e) {
      // Offline fallback - return from Isar
      return await isar.posts
          .filter()
          .communityIdEqualTo(communityId)
          .sortByCreatedAtDesc()
          .findAll();
    }
  }

  Future<void> syncUnsyncedPosts() async {
    final isar = IsarService.isar;
    final unsynced = await isar.posts
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    for (final post in unsynced) {
      try {
        final docRef = _postsRef(post.communityId).doc(post.postId);
        await docRef.set(post.toJson());
        await isar.writeTxn(() async {
          post.isSynced = true;
          await isar.posts.put(post);
        });
      } catch (e) {
        print('Failed to sync post ${post.postId}: $e');
      }
    }
  }
}