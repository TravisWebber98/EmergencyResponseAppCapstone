import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/repositories/community/community_repository.dart';

class FirebaseCommunityRepository implements CommunityRepository {
  final FirebaseFirestore firestore;

  FirebaseCommunityRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _communitiesRef =>
      firestore.collection('communities');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      firestore.collection('accounts');

  @override
  Future<void> addCommunity(Community community) async {
    await _communitiesRef.doc(community.communityId).set({
      'communityId': community.communityId,
      'name': community.name,
      'description': community.description,
      'rules': community.rules,
      'city': community.city,
      'state': community.state,
      'country': community.country,
      'createdAt': Timestamp.fromDate(community.createdAt),
      'updatedAt': Timestamp.fromDate(community.updatedAt),
    });
  }

  @override
  Future<Community?> getCommunityById(String communityId) async {
    final doc = await _communitiesRef.doc(communityId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Community.fromJson(doc.data()!);
  }

  @override
  Future<List<Community>> getAllCommunities() async {
    final snapshot = await _communitiesRef.get();

    return snapshot.docs
        .map((doc) => Community.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> deleteCommunity(String communityId) async {
    await _communitiesRef.doc(communityId).delete();
  }

  @override
  Future<void> clearAllCommunities() async {
    final snapshot = await _communitiesRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> joinCommunity(String userId, String communityId) async {
    await _usersRef.doc(userId).set({
      'joinedCommunityIds': FieldValue.arrayUnion([communityId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<Community>> getJoinedCommunities(String userId) async {
    final userDoc = await _usersRef.doc(userId).get();

    if (!userDoc.exists || userDoc.data() == null) {
      return [];
    }

    final data = userDoc.data()!;
    final List<dynamic> joinedIds = data['joinedCommunityIds'] ?? [];

    if (joinedIds.isEmpty) {
      return [];
    }

    final allCommunities = await getAllCommunities();

    return allCommunities
        .where((community) => joinedIds.contains(community.communityId))
        .toList();
  }

  @override
  Future<List<Community>> getAvailableCommunities(String userId) async {
    final allCommunities = await getAllCommunities();
    final joinedCommunities = await getJoinedCommunities(userId);

    final joinedIds =
    joinedCommunities.map((community) => community.communityId).toSet();

    return allCommunities
        .where((community) => !joinedIds.contains(community.communityId))
        .toList();
  }
}