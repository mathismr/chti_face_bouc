import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../modeles/constantes.dart';
import '../widgets/avatar.dart';
import '../widgets/bouton_camera.dart';
import '../widgets/widget_post.dart';
import 'page_modifier_profil.dart';

class PageProfil extends StatefulWidget {
  final Membre member;
  PageProfil({super.key, required this.member});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ServiceFirestore().postForMember(widget.member.id),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot) {
        final data = snapshot.data;
        final docs = data?.docs;
        final length = docs?.length ?? 0;
        final isMe =
            ServiceAuthentification().isMe(widget.member.id);
        final indexToAdd = (isMe) ? 2 : 1;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: length + indexToAdd,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  Container(
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Stack(
                              children: [
                                // Image de couverture
                                Container(
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: widget.member.coverPicture
                                          .isNotEmpty
                                      ? Image.network(
                                          widget.member.coverPicture,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(),
                                ),
                                // Bouton camera couverture
                                if (isMe)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: BoutonCamera(
                                      type: coverPictureKey,
                                      id: widget.member.id,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Avatar(
                              radius: 75,
                              url: widget.member.profilePicture,
                            ),
                            if (isMe)
                              BoutonCamera(
                                type: profilePictureKey,
                                id: widget.member.id,
                              )
                            else
                              const Center(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.member.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Text(widget.member.description),
                ],
              );
            }
            if (isMe && index == 1) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageModifierProfil(
                            member: widget.member),
                      ),
                    );
                  },
                  child: const Text("Modifier le profil"),
                ),
              );
            }
            final doc = snapshot.data!.docs;
            final current = doc[index - indexToAdd];
            final post = Post(
              reference: current.reference,
              id: current.id,
              map: current.data() as Map<String, dynamic>,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WidgetPost(post: post),
            );
          },
        );
      },
    );
  }
}
