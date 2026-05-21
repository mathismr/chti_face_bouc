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

  // Sondage
  bool _showPoll = false;
  final TextEditingController _pollQuestionController =
      TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _pollDays = 1;

  @override
  void dispose() {
    textController.dispose();
    _pollQuestionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  _sendPost() {
    FocusScope.of(context).requestFocus(FocusNode());

    final hasText = textController.text.isNotEmpty;
    final hasImage = xFile != null;
    final hasPoll = _showPoll &&
        _pollQuestionController.text.isNotEmpty &&
        _optionControllers
            .where((c) => c.text.isNotEmpty)
            .length >= 2;

    if (!hasText && !hasImage && !hasPoll) return;

    final pollOptions = _showPoll
        ? _optionControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList()
        : null;

    ServiceFirestore().createPost(
      member: widget.member,
      text: textController.text,
      image: xFile,
      pollQuestion: _showPoll ? _pollQuestionController.text.trim() : null,
      pollOptions: pollOptions,
      pollDeadlineDays: _showPoll ? _pollDays : null,
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

  void _addOption() {
    if (_optionControllers.length >= 4) return;
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
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
                        icon: const Icon(Icons.camera_alt, size: 32),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showPoll = !_showPoll;
                          });
                        },
                        icon: Icon(
                          Icons.poll,
                          size: 32,
                          color: _showPoll
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
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
          // Sondage
          if (_showPoll)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.poll),
                        const SizedBox(width: 8),
                        const Text(
                          "Sondage",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pollQuestionController,
                      decoration: const InputDecoration(
                        hintText: "Votre question",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._optionControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: "Option ${i + 1}",
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (_optionControllers.length > 2)
                              IconButton(
                                onPressed: () => _removeOption(i),
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                          ],
                        ),
                      );
                    }),
                    if (_optionControllers.length < 4)
                      TextButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une option"),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Duree : "),
                        DropdownButton<int>(
                          value: _pollDays,
                          items: List.generate(7, (i) => i + 1)
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text("$d jour${d > 1 ? 's' : ''}"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _pollDays = value ?? 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _sendPost,
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }
}
