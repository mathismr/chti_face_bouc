import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../modeles/constantes.dart';
import '../modeles/membre.dart';
import '../modeles/message.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/avatar.dart';
import '../widgets/formatage_date.dart';
import '../widgets/gif_picker.dart';

class PageConversation extends StatefulWidget {
  final DocumentReference conversationRef;
  final Membre otherMember;
  const PageConversation({
    super.key,
    required this.conversationRef,
    required this.otherMember,
  });

  @override
  State<PageConversation> createState() => _PageConversationState();
}

class _PageConversationState extends State<PageConversation> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _gifUrl;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && _gifUrl == null) return;
    final myId = ServiceAuthentification().myId;
    if (myId == null) return;
    ServiceFirestore().sendMessage(
      conversationRef: widget.conversationRef,
      senderId: myId,
      text: text,
      gifUrl: _gifUrl,
    );
    _controller.clear();
    setState(() => _gifUrl = null);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = ServiceAuthentification().myId;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Avatar(radius: 16, url: widget.otherMember.profilePicture),
            const SizedBox(width: 10),
            Text(widget.otherMember.fullName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ServiceFirestore()
                  .messagesForConversation(widget.conversationRef),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("Aucun message"));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = Message(
                      reference: docs[index].reference,
                      id: docs[index].id,
                      map: docs[index].data() as Map<String, dynamic>,
                    );
                    final isMe = msg.senderId == myId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (msg.text.isNotEmpty)
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                ),
                              ),
                            if (msg.gifUrl.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    top: msg.text.isNotEmpty ? 6 : 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(msg.gifUrl, width: 200),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              FormatageDate().formatted(msg.date),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.7)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_gifUrl != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(_gifUrl!, height: 100),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _gifUrl = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final url = await GifPicker.show(context);
                      if (url != null) {
                        setState(() => _gifUrl = url);
                      }
                    },
                    icon: const Icon(Icons.gif_box),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Votre message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
