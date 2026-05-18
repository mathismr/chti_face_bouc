import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/avatar.dart';
import '../widgets/widget_vide.dart';
import 'page_profil.dart';

class PageMembres extends StatefulWidget {
  const PageMembres({super.key});

  @override
  State<PageMembres> createState() => _PageMembresState();
}

class _PageMembresState extends State<PageMembres> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ServiceFirestore().allMembers(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          return docs.isNotEmpty
              ? ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    final current = docs[index];
                    final member = Membre(
                      reference: current.reference,
                      id: current.id,
                      map: current.data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      leading: Avatar(
                          radius: 25, url: member.profilePicture),
                      title: Text(member.fullName),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Scaffold(
                                  appBar: AppBar(
                                    title: Text(member.fullName),
                                  ),
                                  body: PageProfil(member: member),
                                ),
                          ),
                        );
                      },
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
