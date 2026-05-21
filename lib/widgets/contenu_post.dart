import 'package:flutter/material.dart';
import '../modeles/post.dart';
import 'entete_membre.dart';
import 'widget_sondage.dart';

class ContenuPost extends StatelessWidget {
  final Post post;
  final Widget? trailing;
  const ContenuPost({super.key, required this.post, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MemberHeader(memberId: post.member, date: post.date, trailing: trailing),
        const SizedBox(height: 8),
        if (post.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(post.text),
          ),
        if (post.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.imageUrl,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(),
        if (post.gifUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.gifUrl,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (post.hasPoll) WidgetSondage(post: post),
      ],
    );
  }
}
