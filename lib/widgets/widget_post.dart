import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../pages/page_detail_post.dart';
import 'contenu_post.dart';

class WidgetPost extends StatelessWidget {
  final Post post;
  const WidgetPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            ContenuPost(post: post),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    final myId = ServiceAuthentification().myId;
                    if (myId != null) {
                      ServiceFirestore()
                          .addLike(memberID: myId, post: post);
                    }
                  },
                  icon: Icon(
                    Icons.star,
                    color: (post.likes
                            .contains(ServiceAuthentification().myId))
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text('${post.likes.length} Likes'),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PageDetailPost(post: post);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.messenger),
                ),
                const Text('Commenter'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
