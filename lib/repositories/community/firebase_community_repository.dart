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

  @override
  Future<AvailableGrouped> getAvailableCommunitiesNearby(String userId) async {
    //Pull user location and the available pool in parallel — they don't
    //depend on each other, and the user doc is small.
    final results = await Future.wait([
      _usersRef.doc(userId).get(),
      getAvailableCommunities(userId),
    ]);

    final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final available = results[1] as List<Community>;

    final userData = userDoc.data();
    final userState = (userData?['state'] as String?)?.trim() ?? '';
    final userCity = (userData?['city'] as String?)?.trim() ?? '';

    //No state on file you can't group, return everything as "others".
    if (userState.isEmpty) {
      return (nearYou: <Community>[], others: available);
    }

    //Case-insensitive comparisons so "TX" / "tx" / " TX " all match.
    bool sameState(Community c) =>
        c.state.trim().toLowerCase() == userState.toLowerCase();
    bool sameCity(Community c) =>
        userCity.isNotEmpty &&
            c.city.trim().toLowerCase() == userCity.toLowerCase();

    final nearYou = <Community>[];
    final others = <Community>[];
    for (final c in available) {
      if (sameState(c)) {
        nearYou.add(c);
      } else {
        others.add(c);
      }
    }

    //Within "Near You", surface same-city first so the user's exact
    //city outranks neighboring cities in the same state.
    nearYou.sort((a, b) {
      final aSame = sameCity(a) ? 0 : 1;
      final bSame = sameCity(b) ? 0 : 1;
      if (aSame != bSame) return aSame - bSame;
      return a.name.compareTo(b.name);
    });
    others.sort((a, b) => a.name.compareTo(b.name));

    return (nearYou: nearYou, others: others);
  }
}