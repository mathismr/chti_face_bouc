import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_firestore.dart';

class PageEcrirePost extends StatefulWidget {
  final Membre member;
  final Function(int) newSelection;
  const PageEcrirePost(
      {super.key, required this.member, required this.newSelection});

  @override
  State<PageEcrirePost> createState() => _PageEcrirePostState();
}

class _PageEcrirePostState extends State<PageEcrirePost> {
  final TextEditingController textController = TextEditingController();
  XFile? xFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _sendPost() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (xFile == null && textController.text.isEmpty) return;
    ServiceFirestore().createPost(
      member: widget.member,
      text: textController.text,
      image: xFile,
    );
    widget.newSelection(0);
  }

  _takePic(ImageSource source) async {
    XFile? newFile =
        await ImagePicker().pickImage(source: source, maxWidth: 500);
    setState(() {
      xFile = newFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.border_color),
                      const SizedBox(width: 8),
                      const Text(
                        "Ecrire un post",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Votre post",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _takePic(ImageSource.gallery),
                        icon: const Icon(Icons.image, size: 32),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => _takePic(ImageSource.camera),
                        icon:
                            const Icon(Icons.camera_alt, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (xFile != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(File(xFile!.path)),
            ),
          ElevatedButton(
            onPressed: _sendPost,
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }
}
