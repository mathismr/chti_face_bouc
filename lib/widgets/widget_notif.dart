import 'package:flutter/material.dart';
import '../modeles/notif.dart' as model;
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../pages/page_detail_post.dart';
import 'entete_membre.dart';

class WidgetNotif extends StatelessWidget {
  final model.Notification notif;
  const WidgetNotif({super.key, required this.notif});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ServiceFirestore().firestorePost.doc(notif.postId).get().then((snapshot) {
          ServiceFirestore().markRead(notif.reference);
          final post = Post(
            reference: snapshot.reference,
            id: snapshot.id,
            map: snapshot.data() as Map<String, dynamic>,
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return PageDetailPost(post: post);
            }),
          );
        });
      },
      child: Container(
        color: (notif.isRead)
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberHeader(
              memberId: notif.from,
              date: notif.date,
            ),
            Text(notif.text),
          ],
        ),
      ),
    );
  }
}
