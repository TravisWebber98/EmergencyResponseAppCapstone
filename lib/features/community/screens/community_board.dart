import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:emergency_response_app/models/community.dart';
import 'package:emergency_response_app/repositories/post/post_repository.dart';
import 'package:emergency_response_app/features/posts/create_post.dart';
import 'package:emergency_response_app/features/posts/edit_post.dart';
import 'package:emergency_response_app/models/post.dart';
import 'package:emergency_response_app/features/posts/screens/image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emergency_response_app/core/services/isar/isar_service.dart';
import 'package:emergency_response_app/repositories/messaging/conversation_repository.dart';
import 'package:emergency_response_app/features/messaging/screens/chat_page.dart';
import 'package:emergency_response_app/features/backup_server/screens/backup_server_demo_page.dart';

class CommunityBoardPage extends StatefulWidget {
  final Community community;

  /// Optional. If set, the board scrolls to this post once posts load and
  /// briefly emphasizes it. Used by tap-through from the Notifications screen.
  final String? highlightPostId;

  const CommunityBoardPage({
    super.key,
    required this.community,
    this.highlightPostId,
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
  late final ConversationRepository _conversationRepository;

  // One GlobalKey per rendered post so we can call Scrollable.ensureVisible
  // on the target when navigating from a notification.
  final Map<String, GlobalKey> _postKeys = {};

  // Briefly outlines the targeted post in green after scroll-to,
  // then fades back to its normal styling.
  String? _flashedPostId;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository(firestore: FirebaseFirestore.instance);
    _conversationRepository = ConversationRepository(
      firestore: FirebaseFirestore.instance,
    );
    _loadMemberCount();
    _loadPosts();
  }

  // After posts arrive, scroll to the highlighted post (if any) and
  // pulse a green border so the user sees what they were taken to.
  void _maybeScrollToHighlighted() {
    final target = widget.highlightPostId;
    if (target == null) return;
    final key = _postKeys[target];
    if (key == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = key.currentContext;
      if (ctx == null) return;
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1, // place a little below the top
      );
      if (!mounted) return;
      setState(() => _flashedPostId = target);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _flashedPostId = null);
    });
  }
  Future<void> _deletePost(Post post, String communityId) async {
    try {
      //Delete from Firestore
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(post.postId)
          .delete();

      //Delete from Isar using the auto-increment ID directly
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.posts.delete(post.isarId);
      });

      //Refresh posts list
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
      _maybeScrollToHighlighted();
    } catch (e) {
      setState(() => loadingPosts = false);
    }
  }

  Future<void> _loadMemberCount() async {
    try {
      //Count users who have this communityId in their joinedCommunityIds
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(community.name),
        actions: [
          IconButton(
            tooltip: 'Community Backup Demo',
            icon: const Icon(Icons.wifi_tethering),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BackupServerDemoPage(
                    defaultCommunityId: community.communityId,
                  ),
                ),
              );

              if (!context.mounted) return;
              await _loadPosts();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Community name
          Text(
            community.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          //Location
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

          //Member count
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

          //Description
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

          //Rules (if present)
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
                      ...posts.map((post) {
                        // Stable GlobalKey per post (created once, reused across
                        // rebuilds) so Scrollable.ensureVisible can find it.
                        final postKey = _postKeys.putIfAbsent(
                          post.postId,
                          () => GlobalKey(),
                        );
                        final isFlashed = _flashedPostId == post.postId;
                        // Border priority: green flash > red urgent > none
                        final RoundedRectangleBorder? shape = isFlashed
                            ? RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.green, width: 2.5),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : (post.isUrgent
                                ? RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.red, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  )
                                : null);
                        return Card(
                        key: postKey,
                        margin: const EdgeInsets.only(bottom: 12),
                        // Urgent posts get a red-tinted background and red border
                        // so they stand out at a glance in the feed.
                        // color: post.isUrgent ? (isDarkMode ? Colors.red.shade50 : Colors.red.shade50) : null,
                        color: post.isUrgent ? Colors.red.shade50 : null,
                        shape: shape,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // URGENT badge above the author row.
                              if (post.isUrgent) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'URGENT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              // Author and date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      post.authorName,
                                      style: TextStyle(fontWeight: FontWeight.bold, 
                                        color: post.isUrgent ? (isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : Colors.black) : null,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${post.createdAt.month}/${post.createdAt.day}/${post.createdAt.year}',
                                        style: TextStyle(color:post.isUrgent ? (isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey) : null, fontSize: 12),
                                      ),
                                      // Edit and delete only show on the user's own posts.
                                      if (post.authorId == currentUserId) ...[
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined,
                                              color: Colors.blue, size: 20),
                                          padding: const EdgeInsets.only(left: 8),
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Edit post',
                                          onPressed: () async {
                                            final updated = await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EditPostPage(post: post),
                                              ),
                                            );
                                            if (updated == true) _loadPosts();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red, size: 20),
                                          padding: const EdgeInsets.only(left: 4),
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Delete post',
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
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Text(
                                post.content,
                                style: TextStyle(
                                  color: post.isUrgent ? (isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : Colors.black) : null,
                                ),
                              ),
                              // Text(post.content),

                              // Optional location chip — present only when the
                              // post had a location attached at create/edit time.
                              if (post.hasLocation &&
                                  (post.locationLabel?.isNotEmpty ?? false)) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: post.isUrgent
                                          ? (isDarkMode
                                              ? Colors.black
                                              : Colors.blue.shade700)
                                          : Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        post.locationLabel!,
                                        style: TextStyle(
                                          color: post.isUrgent
                                              ? (isDarkMode
                                                  ? Colors.black
                                                  : Colors.blue.shade700)
                                              : Colors.blue,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              //Images
                              if (post.imageUrls.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      shrinkWrap: true,
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
                                ),
                              ],


                              //Message author button - only on other users' posts
                              if (post.authorId != currentUserId) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user == null) return;

                                      //Get current user's name from Firestore
                                      final accountDoc = await FirebaseFirestore.instance
                                          .collection('accounts')
                                          .doc(user.uid)
                                          .get();
                                      final currentUserName =
                                          accountDoc.data()?['display'] ?? user.email ?? 'Unknown';

                                      final conversationId = await _conversationRepository
                                          .getOrCreateConversation(
                                        currentUserId: user.uid,
                                        currentUserName: currentUserName,
                                        otherUserId: post.authorId,
                                        otherUserName: post.authorName,
                                      );

                                      if (!context.mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatPage(
                                            conversationId: conversationId,
                                            otherUserId: post.authorId,
                                            otherUserName: post.authorName,
                                          ),
                                        ),
                                      );
                                    },
                                    // icon: const Icon(Icons.message_outlined, size: 16),
                                    // label: const Text('Message'),
                                    icon: Icon(
                                      Icons.message_outlined,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    label: Text(
                                      'Message',
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    
                                  ),
                                ),
                              ],

                              
                            ],
                          ),
                        ),
                      );
                      }),
        ],
      ),
    );
  }
}