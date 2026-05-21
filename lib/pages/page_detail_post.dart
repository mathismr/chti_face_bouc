import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../widgets/gif_picker.dart';
import '../widgets/widget_post.dart';
import '../widgets/liste_commentaire.dart';

class PageDetailPost extends StatefulWidget {
  final Post post;
  const PageDetailPost({super.key, required this.post});

  @override
  State<PageDetailPost> createState() => _PageDetailPostState();
}

class _PageDetailPostState extends State<PageDetailPost> {
  final TextEditingController commentController =
      TextEditingController();
  String? _commentGifUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  _addComment() {
    if (commentController.text.isEmpty && _commentGifUrl == null) return;
    ServiceFirestore().addComment(
      post: widget.post,
      text: commentController.text,
      gifUrl: _commentGifUrl,
    );
    ServiceFirestore().sendNotification(
      to: widget.post.member,
      text: commentController.text.isNotEmpty ? commentController.text : '🎬 GIF',
      postID: widget.post.id,
    );
    commentController.clear();
    setState(() => _commentGifUrl = null);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commentaires"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WidgetPost(post: widget.post),
            if (_commentGifUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(_commentGifUrl!, height: 120),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _commentGifUrl = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final url = await GifPicker.show(context);
                      if (url != null) {
                        setState(() => _commentGifUrl = url);
                      }
                    },
                    icon: const Icon(Icons.gif_box),
                  ),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: "Commentaire",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 400,
              child: ListeCommentaire(postId: widget.post.id),
            ),
          ],
        ),
      ),
    );
  }
}
