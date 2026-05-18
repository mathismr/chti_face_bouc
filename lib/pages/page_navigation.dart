import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/widget_vide.dart';
import 'page_accueil.dart';
import 'page_membres.dart';
import 'page_ecrire_post.dart';
import 'page_notif.dart';
import 'page_profil.dart';

class PageNavigation extends StatefulWidget {
  final String title;
  const PageNavigation({super.key, required this.title});

  @override
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final memberId = ServiceAuthentification().myId;
    return (memberId == null)
        ? const EmptyScaffold()
        : StreamBuilder<DocumentSnapshot>(
            stream: ServiceFirestore().specificMember(memberId),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!;
                final Membre member = Membre(
                  reference: data.reference,
                  id: data.id,
                  map: data.data() as Map<String, dynamic>,
                );
                List<Widget> bodies = [
                  const PageAccueil(),
                  const PageMembres(),
                  PageEcrirePost(
                    member: member,
                    newSelection: (newIndex) {
                      setState(() {
                        index = newIndex;
                      });
                    },
                  ),
                  PageNotif(member: member),
                  PageProfil(member: member),
                ];
                return Scaffold(
                  appBar: AppBar(
                    title: Text(member.fullName),
                  ),
                  bottomNavigationBar: NavigationBar(
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    selectedIndex: index,
                    onDestinationSelected: (int newValue) {
                      setState(() {
                        index = newValue;
                      });
                    },
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home),
                        label: "Accueil",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.group),
                        label: "Membres",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.border_color),
                        label: "Ecrire",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.notifications),
                        label: "Notifications",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person),
                        label: "Profil",
                      ),
                    ],
                  ),
                  body: bodies[index],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return const EmptyScaffold();
              }
            },
          );
  }
}
