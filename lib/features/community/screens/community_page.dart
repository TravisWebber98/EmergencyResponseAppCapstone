import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/community.dart';
import '/providers/community_provider.dart';
import 'create_community_page.dart';

class CommPage extends ConsumerWidget {
  const CommPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the community repository
    final communityRepo = ref.watch(communityRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Community',
            onPressed: () {
              // Navigate to the create community screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateCommunityPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Community>>(
        future: communityRepo.getCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error state
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final communities = snapshot.data!;
            if (communities.isEmpty) {
              return const Center(child: Text('No communities yet.'));
            }
            // Show list of communities
            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return ListTile(
                  title: Text(community.name),
                  subtitle: Text('${community.city}, ${community.state}'),
                  onTap: () {
                    // TODO: Navigate to the community's feed
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}