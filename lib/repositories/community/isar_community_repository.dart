import 'package:isar_community/isar.dart';
import '/models/community.dart';
import 'community_repository.dart';

class IsarCommunityRepository implements CommunityRepository {
  final Isar isar;

  IsarCommunityRepository(this.isar);

  @override
  Future<List<Community>> getCommunities() async {
    return await isar.communitys.where().findAll();
  }

  @override
  Future<Community?> getCommunityById(String communityId) async {
    return await isar.communitys
        .filter()
        .communityIdEqualTo(communityId)
        .findFirst();
  }

  @override
  Future<void> addCommunity(Community community) async {
    await isar.writeTxn(() async {
      await isar.communitys.put(community);
    });
  }

  @override
  Future<void> updateCommunity(Community community) async {
    await isar.writeTxn(() async {
      await isar.communitys.put(community);
    });
  }

  @override
  Future<void> deleteCommunity(String id) async {
    await isar.writeTxn(() async {
      await isar.communitys
          .filter()
          .communityIdEqualTo(id)
          .deleteFirst();
    });
  }
}