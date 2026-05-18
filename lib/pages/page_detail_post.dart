import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
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
    if (commentController.text.isEmpty) return;
    ServiceFirestore().addComment(
      post: widget.post,
      text: commentController.text,
    );
    ServiceFirestore().sendNotification(
      to: widget.post.member,
      text: commentController.text,
      postID: widget.post.id,
    );
    commentController.clear();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
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
