import 'package:emergency_response_app/models/community.dart';

//A split view of communities the user could join — communities in the
//user's home state ([nearYou], same-city sorted first) and everything
// else ([others]).
typedef AvailableGrouped = ({List<Community> nearYou, List<Community> others});

abstract class CommunityRepository {
  Future<void> addCommunity(Community community);
  Future<Community?> getCommunityById(String communityId);
  Future<List<Community>> getAllCommunities();
  Future<void> deleteCommunity(String communityId);
  Future<void> clearAllCommunities();
  Future<void> joinCommunity(String userId, String communityId);
  Future<List<Community>> getJoinedCommunities(String userId);
  Future<List<Community>> getAvailableCommunities(String userId);

  //Returns available communities grouped by proximity to the user's
  //signup city/state. If the user account has no state on file, all
  //available communities fall into [others] and [nearYou] is empty.
  Future<AvailableGrouped> getAvailableCommunitiesNearby(String userId);
}