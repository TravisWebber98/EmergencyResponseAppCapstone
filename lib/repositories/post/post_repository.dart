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
    bool isUrgent = false,
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
      createdAt: now,
      updatedAt: now,
      isUrgent: isUrgent,
      isSynced: false,
    );
    post.imageUrls = []; //imageUrls is a getter/setter instead of a direct field, can't pass it in the constructor

    await isar.writeTxn(() async {
      await isar.posts.put(post);
    });

    //sync to Firestore
    try {
      //Upload images to Cloudinary
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
        'isUrgent': isUrgent,
      });

      //Update Isar with URLs and mark synced
      await isar.writeTxn(() async {
        post.imageUrls = imageUrls;
        post.isSynced = true;
        await isar.posts.put(post);
      });

      //Send out notifications to all community members (except author)
      //when the post is urgent. Done after the post is saved so we have
      //a stable postId to link from each notification.
      if (isUrgent) {
        await _fanOutUrgentNotifications(
          communityId: communityId,
          postId: docRef.id,
          authorId: authorId,
          authorName: authorName,
          content: content,
        );
      }
    } catch (e) {
      print('Firestore sync failed, will retry: $e');
    }
  }

  //Update an existing post. Any of text/images/urgency can change.
  // [keptImageUrls] is the subset of the original image URLs the user
  // chose to keep; [newImages] are freshly-picked local files to upload.
  // The final imageUrls written to Firestore is keptImageUrls + uploaded URLs.
  Future<void> updatePost({
    required String communityId,
    required String postId,
    required String content,
    required bool isUrgent,
    List<String> keptImageUrls = const [],
    List<File> newImages = const [],
  }) async {
    final isar = IsarService.isar;
    final docRef = _postsRef(communityId).doc(postId);

    //Upload any new images first so we can write a single Firestore update
    List<String> uploadedUrls = [];
    if (newImages.isNotEmpty) {
      uploadedUrls = await CloudinaryService.uploadImages(newImages);
    }
    final finalUrls = [...keptImageUrls, ...uploadedUrls];

    await docRef.update({
      'content': content,
      'imageUrls': finalUrls,
      'isUrgent': isUrgent,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    //Mirror the change in Isar so offline reads stay consistent
    final cached = await isar.posts
        .filter()
        .postIdEqualTo(postId)
        .findFirst();
    if (cached != null) {
      await isar.writeTxn(() async {
        cached.content = content;
        cached.imageUrls = finalUrls;
        cached.isUrgent = isUrgent;
        cached.updatedAt = DateTime.now();
        cached.isSynced = true;
        await isar.posts.put(cached);
      });
    }
  }

  //Writes a notification doc into each community member's
  // `accounts/{uid}/notifications` subcollection — except the author.
  // Done as a single batch write so partial failures don't leave
  // some members notified and others not.
  Future<void> _fanOutUrgentNotifications({
    required String communityId,
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    try {
      //Look up community name once and denormalize into each notification.
      //Saves an extra read per notification on the receiver's side and lets
      //the Notifications screen show the source community without a join.
      final communitySnap = await firestore
          .collection('communities')
          .doc(communityId)
          .get();
      final communityName =
          (communitySnap.data()?['name'] as String?) ?? 'a community';

      final membersSnap = await firestore
          .collection('accounts')
          .where('joinedCommunityIds', arrayContains: communityId)
          .get();

      final batch = firestore.batch();
      final preview = content.length > 120
          ? '${content.substring(0, 120)}…'
          : content;

      for (final memberDoc in membersSnap.docs) {
        if (memberDoc.id == authorId) continue;

        final notifRef = firestore
            .collection('accounts')
            .doc(memberDoc.id)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'notificationId': notifRef.id,
          'type': 'urgent_post',
          'title': 'Urgent post from $authorName',
          'body': preview,
          'communityId': communityId,
          'communityName': communityName,
          'postId': postId,
          'authorId': authorId,
          'authorName': authorName,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      //Don't fail the post itself if notifications can't be sent
      print('Urgent notification distribution failed: $e');
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

      //Cache to Isar
      await isar.writeTxn(() async {
        await isar.posts.putAll(posts);
      });

      return posts;
    } catch (e) {
      //Offline fallback - return from Isar
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
