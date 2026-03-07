import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/community.dart';
import 'community_repository.dart';

class FirebaseCommunityRepository implements CommunityRepository {
  final FirebaseFirestore firestore;

  FirebaseCommunityRepository(this.firestore);

  CollectionReference get _communities =>
      firestore.collection('communities');

  @override
  Future<List<Community>> getCommunities() async {
    final snapshot = await _communities.get();

    return snapshot.docs
        .map((doc) => Community.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Community?> getCommunityById(String id) async {
    final doc = await _communities.doc(id).get();

    if (!doc.exists) return null;

    return Community.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addCommunity(Community community) async {
    await _communities.doc(community.communityId).set(community.toJson());
  }

  @override
  Future<void> updateCommunity(Community community) async {
    await _communities.doc(community.communityId).update(community.toJson());
  }

  @override
  Future<void> deleteCommunity(String id) async {
    await _communities.doc(id).delete();
  }

  Stream<List<Community>> streamCommunities() {
    return firestore.collection('communities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Community.fromJson(doc.data())).toList();
    });
  }
}