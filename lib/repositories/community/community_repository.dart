import 'package:emergency_response_app/models/community.dart';

abstract class CommunityRepository {
  Future<void> addCommunity(Community community);
  Future<Community?> getCommunityById(String communityId);
  Future<List<Community>> getAllCommunities();
  Future<void> deleteCommunity(String communityId);
  Future<void> clearAllCommunities();
  Future<void> joinCommunity(String userId, String communityId);
  Future<List<Community>> getJoinedCommunities(String userId);
  Future<List<Community>> getAvailableCommunities(String userId);
}