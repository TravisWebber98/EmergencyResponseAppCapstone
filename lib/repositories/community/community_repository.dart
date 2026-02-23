import 'package:emergency_response_app/models/community.dart';

abstract class CommunityRepository {
  Future<void> addCommunity(Community community);
  Future<Community?> getCommunityById(String communityId);
  Future<List<Community>> getAllCommunities();
  Future<void> deleteCommunity(String communityId);
  Future<void> clearAllCommunities();
}