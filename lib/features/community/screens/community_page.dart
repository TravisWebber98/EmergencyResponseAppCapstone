import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/repositories/community/community_repository.dart';
import 'package:emergency_response_app/features/community/screens/community_board.dart';
import 'package:emergency_response_app/features/community/screens/create_community.dart';
import 'package:emergency_response_app/features/backup_server/screens/backup_server_demo_page.dart';


class CommPage extends StatefulWidget {
  final CommunityRepository repository;
  //final String userId;

  const CommPage({
    super.key,
    required this.repository,
    //required this.userId,
  });

  @override
  State<CommPage> createState() => _CommPageState();
}

class _CommPageState extends State<CommPage> {
  List<Community> joinedCommunities = [];
  // Available communities, split by proximity to the user's signup state.
  List<Community> nearYouCommunities = [];
  List<Community> otherCommunities = [];
  bool isLoading = true;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    loadCommunities();
  }

  Future<void> loadCommunities() async {
    setState(() {
      isLoading = true;
    });

    try {
      final joined =
      await widget.repository.getJoinedCommunities(_userId);
      final available =
      await widget.repository.getAvailableCommunitiesNearby(_userId);

      setState(() {
        joinedCommunities = joined;
        nearYouCommunities = available.nearYou;
        otherCommunities = available.others;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load communities: $e')),
      );
    }
  }

  Future<void> joinCommunity(Community community) async {
    try {
      await widget.repository.joinCommunity(
        _userId,
        community.communityId,
      );

      await loadCommunities();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${community.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join community: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Communities"),
      // )
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCommunityPage(),
            ),
          );
          // Refresh the list if a community was created
          if (created == true) {
            loadCommunities();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadCommunities,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Joined Communities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            if (joinedCommunities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("You have not joined any communities yet."),
              ),

            ...joinedCommunities.map(
                  (community) => Card(
                child: ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(community.name),
                  subtitle:
                  Text('${community.city}, ${community.state}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityBoardPage(community: community),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            //"Near You" — communities matching the user's home state,
            //with same-city sorted to the top by the repository.
            //Hidden entirely when the user has no state on file or
            //when no available community happens to be in their state.
            if (nearYouCommunities.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.near_me, size: 20, color: Colors.blue),
                  SizedBox(width: 6),
                  Text(
                    "Near You",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...nearYouCommunities.map((c) => _availableCard(c)),
              const SizedBox(height: 24),
            ],

            //"All Others" — everything else not joined and not near you.
            //Header text shifts to a friendlier "Available Communities"
            //when there's no Near You section above ( the user has
            //no state, or no nearby matches). That way the page never
            //looks like it's missing a section.
            Text(
              nearYouCommunities.isEmpty
                  ? "Available Communities"
                  : "All Others",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            if (otherCommunities.isEmpty && nearYouCommunities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("No available communities right now."),
              ),

            ...otherCommunities.map((c) => _availableCard(c)),
          ],
        ),
      ),
    );
  }

  Widget _availableCard(Community community) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(community.name),
        subtitle: Text('${community.city}, ${community.state}'),
        trailing: ElevatedButton(
          onPressed: () => joinCommunity(community),
          child: const Text("Join"),
        ),
      ),
    );
  }
}