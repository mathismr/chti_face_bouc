import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/constantes.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/avatar.dart';
import '../widgets/formatage_date.dart';
import '../widgets/widget_vide.dart';
import 'page_conversation.dart';

class PageConversations extends StatelessWidget {
  const PageConversations({super.key});

  void _showMemberPicker(BuildContext context) {
    final myId = ServiceAuthentification().myId;
    if (myId == null) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: ServiceFirestore().allMembers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs
              .where((doc) => doc.id != myId)
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final member = Membre(
                reference: doc.reference,
                id: doc.id,
                map: doc.data() as Map<String, dynamic>,
              );
              return ListTile(
                leading: Avatar(radius: 22, url: member.profilePicture),
                title: Text(member.fullName),
                onTap: () async {
                  Navigator.of(context).pop();
                  final convRef = await ServiceFirestore()
                      .getOrCreateConversation(myId, member.id);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PageConversation(
                          conversationRef: convRef,
                          otherMember: member,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = ServiceAuthentification().myId;
    if (myId == null) return const EmptyBody();
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: ServiceFirestore().conversationsForMember(myId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("Aucune conversation"),
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(data[participantsKey]);
              final otherId = participants.firstWhere((id) => id != myId);
              final lastMessage = data[lastMessageKey] ?? "";
              final lastDate = data[lastMessageDateKey] ?? 0;
              return StreamBuilder<DocumentSnapshot>(
                stream: ServiceFirestore().specificMember(otherId),
                builder: (context, memberSnap) {
                  if (!memberSnap.hasData || !memberSnap.data!.exists) {
                    return const SizedBox();
                  }
                  final memberDoc = memberSnap.data!;
                  final member = Membre(
                    reference: memberDoc.reference,
                    id: memberDoc.id,
                    map: memberDoc.data() as Map<String, dynamic>,
                  );
                  return ListTile(
                    leading: Avatar(radius: 25, url: member.profilePicture),
                    title: Text(member.fullName),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: lastDate > 0
                        ? Text(
                            FormatageDate().formatted(lastDate),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PageConversation(
                            conversationRef: docs[index].reference,
                            otherMember: member,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberPicker(context),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
