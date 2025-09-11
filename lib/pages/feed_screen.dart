import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skillsync/models/livestream.dart';
import 'package:skillsync/widgets/loading_indicatior.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Users',
              style: TextStyle(
                fontSize: 20 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('livestream')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No live streams"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      LiveStream post =
                      LiveStream.fromMap(doc.data());

                      return InkWell(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Responsive thumbnail
                              Flexible(
                                flex: 2,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      post.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Responsive text area
                              Flexible(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      post.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16 * textScale,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      post.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * textScale,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${post.viewers} watching',
                                      style: TextStyle(fontSize: 12 * textScale),
                                    ),
                                    Text(
                                      'Started ${timeago.format(post.startedAt.toDate())}',
                                      style: TextStyle(fontSize: 12 * textScale),
                                    ),
                                  ],
                                ),
                              ),

                              // More button stays fixed
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
