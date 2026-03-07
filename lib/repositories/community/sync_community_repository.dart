import 'dart:async';
import '/models/community.dart';
import 'community_repository.dart';
import 'isar_community_repository.dart';
import 'firebase_community_repository.dart';

class SyncCommunityRepository implements CommunityRepository {
  final IsarCommunityRepository local;
  final FirebaseCommunityRepository remote;

  StreamSubscription? _remoteListener;

  SyncCommunityRepository({
    required this.local,
    required this.remote,
  }) {
    _startRemoteListener();
  }

  /// Read all communities from local Isar
  @override
  Future<List<Community>> getCommunities() async {
    return await local.getCommunities();
  }

  /// Read a single community by ID from local Isar
  @override
  Future<Community?> getCommunityById(String communityId) async {
    return await local.getCommunityById(communityId);
  }

  @override
  Future<void> addCommunity(Community community) async {
    // Write locally first
    await local.addCommunity(community);

    // Sync to Firebase asynchronously
    unawaited(remote.addCommunity(community));
  }

  /// Create or update a community locally, then sync to Firebase
  @override
  Future<void> updateCommunity(Community community) async {
    //  Write locally
    await local.updateCommunity(community);

    // Sync to Firebase in the background
    unawaited(remote.updateCommunity(community));
  }

  /// Delete community locally, then remotely
  @override
  Future<void> deleteCommunity(String communityId) async {
    await local.deleteCommunity(communityId);
    unawaited(remote.deleteCommunity(communityId));
  }

  /// Listen to remote changes and merge into local Isar
  void _startRemoteListener() {
    _remoteListener = remote.streamCommunities().listen((remoteCommunities) async {
      for (var community in remoteCommunities) {
        await local.updateCommunity(community); // merge remote changes into Isar
      }
    });
  }

  /// Stop remote listener when no longer needed
  Future<void> dispose() async {
    await _remoteListener?.cancel();
  }
}