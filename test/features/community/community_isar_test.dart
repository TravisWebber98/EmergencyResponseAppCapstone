import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:emergency_response_app/models/community.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;

  setUpAll(() async {
    // This tells Isar where to look for the .dll file
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // For unit tests, use a temporary directory
    isar = await Isar.open(
      [CommunitySchema],
      directory: Directory.systemTemp.path,
      inspector: false,
    );

    await isar.writeTxn(() => isar.communitys.clear());
  });

  tearDown(() async {
    await isar.close();
  });

  test('Create and fetch Community', () async {
    // Create a new Community
    final community = Community(
      communityId: 'test001',
      name: 'Test Community',
      description: 'A community for testing purposes',
      city: 'College Station',
      state: 'TX',
      country: 'USA',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Isar
    await isar.writeTxn(() async {
      await isar.communitys.put(community);
    });

    // Fetch by unique communityId
    final fetched = await isar.communitys.filter()
        .communityIdEqualTo('test001')
        .findFirst();

    // Assertions
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Test Community');
    expect(fetched.city, 'College Station');
    expect(fetched.state, 'TX');
    expect(fetched.country, 'USA');
  });
}