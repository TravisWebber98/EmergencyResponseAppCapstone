import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emergency_response_app/repositories/community/community_repositories.dart';

// Provider for the Isar instance
final isarProvider = Provider<Isar>((ref) {
  // The Isar instance should be initialized in main.dart before using this provider
  throw UnimplementedError(
      'Initialize Isar in main.dart and provide the instance here.');
});

// Provider for the SyncCommunityRepository
final communityRepositoryProvider =
Provider<CommunityRepository>((ref) {
  // Watch the Isar instance
  final isar = ref.watch(isarProvider);

  // Create local and remote repositories
  final localRepo = IsarCommunityRepository(isar);
  final remoteRepo = FirebaseCommunityRepository(FirebaseFirestore.instance);

  // Return the Sync repository
  return SyncCommunityRepository(local: localRepo, remote: remoteRepo);
});