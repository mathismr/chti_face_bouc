import 'package:flutter/material.dart';
import '../modeles/membre.dart';
import '../modeles/constantes.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';

class PageModifierProfil extends StatefulWidget {
  final Membre member;
  const PageModifierProfil({super.key, required this.member});

  @override
  State<PageModifierProfil> createState() => _PageModifierProfilState();
}

class _PageModifierProfilState extends State<PageModifierProfil> {
  late TextEditingController surnameController;
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    surnameController =
        TextEditingController(text: widget.member.surname);
    nameController = TextEditingController(text: widget.member.name);
    descriptionController =
        TextEditingController(text: widget.member.description);
  }

  @override
  void dispose() {
    surnameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  _onValidate() {
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> map = {};
    final member = widget.member;

    if (nameController.text.isNotEmpty &&
        nameController.text != member.name) {
      map[nameKey] = nameController.text;
    }

    if (surnameController.text.isNotEmpty &&
        surnameController.text != member.surname) {
      map[surnameKey] = surnameController.text;
    }

    if (descriptionController.text.isNotEmpty &&
        descriptionController.text != member.description) {
      map[descriptionKey] = descriptionController.text;
    }

    ServiceFirestore().updateMember(id: member.id, data: map);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        actions: [
          IconButton(
            onPressed: _onValidate,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(
                  labelText: "Prenom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Se deconnecter"),
                      content: const Text(
                          "Voulez vous vous deconnecter ?"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("NON"),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text("OUI"),
                        ),
                      ],
                    ),
                  );
                  if (result == true) {
                    await ServiceAuthentification().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Se deconnecter"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Supprimer le compte"),
                      content: const Text(
                          "Cette action est irréversible. Voulez-vous vraiment supprimer votre compte ?"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("NON"),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text("OUI"),
                        ),
                      ],
                    ),
                  );
                  if (result == true) {
                    final memberId = ServiceAuthentification().myId;
                    final authDeleted = await ServiceAuthentification().deleteAccount();
                    if (authDeleted && memberId != null) {
                      await ServiceFirestore().deleteMember(id: memberId);
                    }
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Supprimer mon compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
