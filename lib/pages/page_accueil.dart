import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/widget_post.dart';
import '../widgets/widget_vide.dart';

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ServiceFirestore().allPosts(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          return docs.isNotEmpty
              ? ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final current = docs[index];
                    final post = Post(
                      reference: current.reference,
                      id: current.id,
                      map: current.data() as Map<String, dynamic>,
                    );
                    return WidgetPost(post: post);
                  },
                )
              : const EmptyBody();
        }
        return const EmptyBody();
      },
    );
  }
}
