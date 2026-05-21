import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../pages/page_detail_post.dart';
import 'contenu_post.dart';

class WidgetPost extends StatelessWidget {
  final Post post;
  const WidgetPost({super.key, required this.post});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le post'),
        content: const Text('Voulez-vous vraiment supprimer ce post ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ServiceFirestore().deletePost(post: post);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMyPost = ServiceAuthentification().isMe(post.member);
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            ContenuPost(
              post: post,
              trailing: isMyPost
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
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
