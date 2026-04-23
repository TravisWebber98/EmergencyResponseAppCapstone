import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/repositories/post/post_repository.dart';
import 'package:emergency_response_app/features/posts/create_post.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:emergency_response_app/features/posts/screens/image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emergency_response_app/core/services/isar/isar_service.dart';


class CommunityBoardPage extends StatefulWidget {
  final Community community;

  const CommunityBoardPage({
    super.key,
    required this.community,
  });

  @override
  State<CommunityBoardPage> createState() => _CommunityBoardPageState();
}

class _CommunityBoardPageState extends State<CommunityBoardPage> {
  int memberCount = 0;
  bool loadingCount = true;
  List<Post> posts = [];
  bool loadingPosts = true;
  late final PostRepository _postRepository;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository(
      firestore: FirebaseFirestore.instance,
    );
    _loadMemberCount();
    _loadPosts();
  }
  Future<void> _deletePost(Post post, String communityId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(post.postId)
          .delete();

      // Delete from Isar using the auto-increment ID directly
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.posts.delete(post.isarId);
      });

      // Refresh the posts list
      _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    }
  }
  Future<void> _loadPosts() async {
    try {
      final fetched = await _postRepository.getPosts(widget.community.communityId);
      setState(() {
        posts = fetched;
        loadingPosts = false;
      });
    } catch (e) {
      setState(() => loadingPosts = false);
    }
  }

  Future<void> _loadMemberCount() async {
    try {
      // Count users who have this communityId in their joinedCommunityIds
      final snapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('joinedCommunityIds', arrayContains: widget.community.communityId)
          .get();

      setState(() {
        memberCount = snapshot.docs.length;
        loadingCount = false;
      });
    } catch (e) {
      setState(() => loadingCount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final community = widget.community;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;


    return Scaffold(
      appBar: AppBar(
        title: Text(community.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Community name
          Text(
            community.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${community.city}, ${community.state}, ${community.country}',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Member count
          Row(
            children: [
              const Icon(Icons.group, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              loadingCount
                  ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                '$memberCount member${memberCount == 1 ? '' : 's'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(community.description),
                ],
              ),
            ),
          ),

          // Rules (if present)
          if (community.rules != null && community.rules!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rules',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(community.rules!),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Post feed placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePostPage(
                        communityId: widget.community.communityId,
                      ),
                    ),
                  );
                  if (created == true) _loadPosts();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Post'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Posts list
                    if (loadingPosts)
                      const Center(child: CircularProgressIndicator())
                    else if (posts.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No posts yet. Be the first to post!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      ...posts.map((post) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author and date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${post.createdAt.month}/${post.createdAt.day}/${post.createdAt.year}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      // Only show delete button if this is the current user's post
                                      if (post.authorId == currentUserId)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () async {
                                            // Show confirmation dialog first
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Post'),
                                                content: const Text('Are you sure you want to delete this post?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await _deletePost(post, widget.community.communityId);
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Content
                              Text(post.content),
                              // Images
                              if (post.imageUrls.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.imageUrls.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, index) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ImageViewerPage(
                                              imageUrls: post.imageUrls,
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          post.imageUrls[index],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
        ],
      ),
    );
  }
}