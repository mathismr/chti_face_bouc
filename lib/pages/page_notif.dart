import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/membre.dart';
import '../modeles/notif.dart' as model;
import '../services_firebase/service_firestore.dart';
import '../widgets/widget_notif.dart';
import '../widgets/widget_vide.dart';

class PageNotif extends StatefulWidget {
  final Membre member;
  const PageNotif({super.key, required this.member});

  @override
  State<PageNotif> createState() => _PageNotifState();
}

class _PageNotifState extends State<PageNotif> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          ServiceFirestore().notificationForUser(widget.member.id),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          return docs.isNotEmpty
              ? ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final current = docs[index];
                    final notif = model.Notification(
                      reference: current.reference,
                      id: current.id,
                      data: current.data() as Map<String, dynamic>,
                    );
                    return WidgetNotif(notif: notif);
                  },
                )
              : const EmptyBody();
        }
        return const EmptyBody();
      },
    );
  }
}
