import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/commentaire.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/widget_vide.dart';
import 'entete_membre.dart';

class ListeCommentaire extends StatelessWidget {
  final String postId;
  const ListeCommentaire({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ServiceFirestore().postComment(postId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          return docs.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final current = docs[index];
                    final commentaire = Commentaire(
                      reference: current.reference,
                      id: current.id,
                      map: current.data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      title: MemberHeader(
                        memberId: commentaire.member,
                        date: commentaire.date,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (commentaire.text.isNotEmpty)
                            Text(commentaire.text),
                          if (commentaire.gifUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  commentaire.gifUrl,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : const EmptyBody();
        }
        return const EmptyBody();
      },
    );
  }
}
