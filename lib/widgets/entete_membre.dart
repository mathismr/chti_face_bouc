import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/avatar.dart';
import '../widgets/formatage_date.dart';

class MemberHeader extends StatelessWidget {
  final String memberId;
  final int date;
  final Widget? trailing;
  const MemberHeader({super.key, required this.memberId, required this.date, this.trailing});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ServiceFirestore().specificMember(memberId),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!;
          final member = Membre(
            reference: data.reference,
            id: data.id,
            map: data.data() as Map<String, dynamic>,
          );
          return Row(
            children: [
              Avatar(radius: 15, url: member.profilePicture),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  member.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                FormatageDate().formatted(date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (trailing != null) trailing!,
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
