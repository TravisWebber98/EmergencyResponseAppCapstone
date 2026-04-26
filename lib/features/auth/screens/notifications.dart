import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/features/community/screens/community_board.dart';

/// Notifications screen — reads from
/// `accounts/{currentUid}/notifications`, sorted by createdAt desc.
/// Tapping a notification marks it as read and (for urgent_post type)
/// navigates to the community board scrolled to the relevant post.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('Sign in to see notifications.'));
    }

    final notificationsRef = FirebaseFirestore.instance
        .collection('accounts')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: notificationsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load notifications:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;

            final title = (data['title'] ?? 'Notification') as String;
            final body = (data['body'] ?? '') as String;
            final read = (data['read'] ?? false) as bool;
            final type = (data['type'] ?? '') as String;
            final communityName = (data['communityName'] ?? '') as String;
            final communityId = (data['communityId'] ?? '') as String;
            final postId = (data['postId'] ?? '') as String;
            final createdAt = data['createdAt'] is Timestamp
                ? (data['createdAt'] as Timestamp).toDate()
                : null;

            final isUrgent = type == 'urgent_post';
            final canNavigate = isUrgent &&
                communityId.isNotEmpty &&
                postId.isNotEmpty;

            return ListTile(
              tileColor: read
                  ? null
                  : (isUrgent
                      ? Colors.red.shade50
                      : Colors.blue.shade50),
              leading: CircleAvatar(
                backgroundColor:
                    isUrgent ? Colors.red : Colors.blueGrey,
                child: Icon(
                  isUrgent
                      ? Icons.warning_amber_rounded
                      : Icons.notifications,
                  color: Colors.white,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (body.isNotEmpty) Text(body),
                  // Community label — only on notifications that came from one.
                  if (communityName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.group,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'From $communityName',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatTime(createdAt),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11),
                      ),
                    ),
                ],
              ),
              trailing: canNavigate
                  ? Icon(
                      Icons.chevron_right,
                      color: read ? Colors.grey : Colors.red,
                    )
                  : (read
                      ? null
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )),
              onTap: () async {
                // Mark read first so the UI updates even if the navigation fails.
                if (!read) {
                  await doc.reference.update({'read': true});
                }
                if (!canNavigate) return;
                if (!context.mounted) return;
                await _openPost(
                  context: context,
                  communityId: communityId,
                  postId: postId,
                );
              },
            );
          },
        );
      },
    );
  }

  // Fetch the community doc, then push the community board with the
  // post's id so the board scrolls to and highlights it.
  Future<void> _openPost({
    required BuildContext context,
    required String communityId,
    required String postId,
  }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .get();

      if (!snap.exists || snap.data() == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That community no longer exists.')),
        );
        return;
      }

      final community = Community.fromJson(snap.data()!);

      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityBoardPage(
            community: community,
            highlightPostId: postId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open post: $e')),
      );
    }
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.month}/${t.day}/${t.year}';
  }
}
