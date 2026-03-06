import 'package:isar_community/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post.dart';

class PostRepository {
  final Isar isar;
  final FirebaseFirestore firestore;

  PostRepository({required this.isar, required this.firestore});

  CollectionReference get _postsRef => firestore.collection('posts');

  Future<void> createPost(Post post) async {
    await isar.writeTxn(() async {
      await isar.posts.put(post);
    });

    try {
      final docRef = await _postsRef.add({
        'title': post.title,
        'content': post.content,
        'authorId': post.authorId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await isar.writeTxn(() async {
        post.firestoreId = docRef.id;
        post.isSynced = true;
        await isar.posts.put(post);
      });
    } catch (e) {
      print('Firestore write failed, queued for sync: $e');
    }
  }

  Future<List<Post>> getLocalPosts() async {
    return await isar.posts.where().findAll();
  }

  Future<void> syncUnsyncedPosts() async {
    final unsynced = await isar.posts
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    for (final post in unsynced) {
      await createPost(post);
    }
  }
}