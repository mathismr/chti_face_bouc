import 'package:flutter/material.dart';
import '../modeles/post.dart';
import 'entete_membre.dart';

class ContenuPost extends StatelessWidget {
  final Post post;
  const ContenuPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MemberHeader(memberId: post.member, date: post.date),
        const SizedBox(height: 8),
        if (post.imageUrl.isNotEmpty)
          Image.network(
            post.imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          )
        else
          Container(),
        if (post.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(post.text),
          ),
      ],
    );
  }
}
