import 'package:isar_community/isar.dart';

part 'post.g.dart';

@collection
class Post {
  Id id = Isar.autoIncrement;

  String? firestoreId;
  String? title;
  String? content;
  String? authorId;
  DateTime? createdAt;
  bool isSynced = false;
}