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
  List<Community> availableCommunities = [];
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
      await widget.repository.getAvailableCommunities(_userId);

      setState(() {
        joinedCommunities = joined;
        availableCommunities = available;
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
            Card(
              color: Colors.grey.shade50,
              child: ListTile(
                leading: const Icon(Icons.wifi_tethering),
                title: const Text('Backup Server Demo'),
                subtitle: const Text(
                  'Test PocketBase disaster backup connection',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupServerDemoPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

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

            const Text(
              "Available Communities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            if (availableCommunities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("No available communities right now."),
              ),

            ...availableCommunities.map(
                  (community) => Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(community.name),
                  subtitle:
                  Text('${community.city}, ${community.state}'),
                  trailing: ElevatedButton(
                    onPressed: () => joinCommunity(community),
                    child: const Text("Join"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}