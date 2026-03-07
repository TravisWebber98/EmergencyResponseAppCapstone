import '/models/community.dart';

abstract class CommunityRepository {
  Future<List<Community>> getCommunities();

  Future<Community?> getCommunityById(String id);

  Future<void> addCommunity(Community community);

  Future<void> updateCommunity(Community community);

  Future<void> deleteCommunity(String id);
}