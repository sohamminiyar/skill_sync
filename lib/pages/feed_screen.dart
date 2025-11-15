import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skillsync/models/livestream.dart';
import 'package:skillsync/pages/broadcast_screen.dart';
import 'package:skillsync/resources/firestore_methods.dart';
import 'package:skillsync/responsive/responsive_layout.dart';
import 'package:skillsync/widgets/loading_indicatior.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _getImageUrl(String imagePath) => imagePath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWeb = kIsWeb;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Users',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: size.height * 0.03),

            // 🔑 Use Flexible instead of Expanded here
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('livestream')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading streams: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.live_tv, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No live streams right now",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Check back later for new streams",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // For web, use grid layout
                  if (isWeb) {
                    return _buildWebGrid(docs);
                  }

                  // For desktop + mobile
                  return ResponsiveLatout(
                    desktopBody: _buildDesktopGrid(docs),
                    mobileBody: _buildMobileList(docs),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- WEB GRID ----------
  Widget _buildWebGrid(List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 320).floor().clamp(1, 4);

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4 / 3, // 👈 taller card
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            LiveStream post =
            LiveStream.fromMap(docs[index].data() as Map<String, dynamic>);
            return _buildDesktopStreamCard(post, context);
          },
        );
      },
    );
  }

  // ---------- DESKTOP GRID ----------
  Widget _buildDesktopGrid(List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 400).floor().clamp(1, 4);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 4 / 3, // 👈 more space
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            LiveStream post =
            LiveStream.fromMap(docs[index].data() as Map<String, dynamic>);
            return _buildDesktopStreamCard(post, context);
          },
        );
      },
    );
  }

  // ---------- MOBILE LIST ----------
  Widget _buildMobileList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        LiveStream post =
        LiveStream.fromMap(docs[index].data() as Map<String, dynamic>);
        return _buildStreamListItem(post, context);
      },
    );
  }

  // ---------- DESKTOP CARD ----------
  Widget _buildDesktopStreamCard(LiveStream post, BuildContext context) {
    final imageUrl = _getImageUrl(post.image);

    return InkWell(
      onTap: () async {
        await FirestoreMethods().updateViewCount(post.channelId, true);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BroadcastScreen(
              isBroadcaster: false,
              channelId: post.channelId,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Started ${timeago.format(post.startedAt.toDate())}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- MOBILE LIST ITEM ----------
  Widget _buildStreamListItem(LiveStream post, BuildContext context) {
    final imageUrl = _getImageUrl(post.image);

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          await FirestoreMethods().updateViewCount(post.channelId, true);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BroadcastScreen(
                isBroadcaster: false,
                channelId: post.channelId,
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text('${post.viewers} watching'),
                  Text(
                    'Started ${timeago.format(post.startedAt.toDate())}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // More button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}