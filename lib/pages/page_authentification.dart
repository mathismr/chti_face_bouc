import 'package:flutter/material.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../modeles/constantes.dart';

class PageAuthentification extends StatefulWidget {
  final String title;
  const PageAuthentification({super.key, required this.title});

  @override
  State<PageAuthentification> createState() => _PageAuthentificationState();
}

class _PageAuthentificationState extends State<PageAuthentification> {
  bool accountExists = true;
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    surnameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  _onSelectedChanged(Set<bool> newValue) {
    setState(() {
      accountExists = newValue.first;
    });
  }

  _handleAuth() async {
    if (accountExists) {
      await ServiceAuthentification().signIn(
        email: mailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } else {
      final result = await ServiceAuthentification().createAccount(
        email: mailController.text.trim(),
        password: passwordController.text.trim(),
        surname: surnameController.text.trim(),
        name: nameController.text.trim(),
      );
      if (result != null && result.isNotEmpty && result != "Erreur inconnue") {
        ServiceFirestore().addMember(
          id: result,
          data: {
            memberIdKey: result,
            nameKey: nameController.text.trim(),
            surnameKey: surnameController.text.trim(),
            "email": mailController.text.trim(),
            profilePictureKey: "",
            coverPictureKey: "",
            descriptionKey: "",
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const FlutterLogo(size: 150);
                },
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text("Creer l'te compte"),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text("J'y va connecter"),
                  ),
                ],
                selected: {accountExists},
                onSelectionChanged: _onSelectedChanged,
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: mailController,
                        decoration: const InputDecoration(
                          labelText: "Adresse mail",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                        ),
                        obscureText: true,
                      ),
                      if (!accountExists) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: surnameController,
                          decoration: const InputDecoration(
                            labelText: "Prenom",
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Nom",
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleAuth,
                        child: Text(
                            accountExists ? "Ch'ti parti !" : "Creer min compte"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
