import 'package:flutter/material.dart';
import '../modeles/post.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import 'formatage_date.dart';

class WidgetSondage extends StatelessWidget {
  final Post post;
  const WidgetSondage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final myId = ServiceAuthentification().myId ?? "";
    final myVote = post.votedOption(myId);
    final hasVoted = myVote != null;
    final expired = post.isPollExpired;
    final showResults = hasVoted || expired;
    final total = post.totalVotes;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  post.pollQuestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...post.pollOptions.map((option) {
            final votes = post.pollVotes[option]?.length ?? 0;
            final percentage = total > 0 ? votes / total : 0.0;
            final isMyVote = myVote == option;

            if (showResults) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isMyVote)
                          Icon(Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                        if (isMyVote) const SizedBox(width: 4),
                        Expanded(child: Text(option)),
                        Text(
                          "$votes vote${votes > 1 ? 's' : ''} (${(percentage * 100).toStringAsFixed(0)}%)",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        color: isMyVote
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ServiceFirestore().votePoll(
                        post: post,
                        option: option,
                        userId: myId,
                      );
                    },
                    child: Text(option),
                  ),
                ),
              );
            }
          }),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$total vote${total > 1 ? 's' : ''}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                expired
                    ? "Sondage termine"
                    : "Fin le ${FormatageDate().formatted(post.pollDeadline)}",
                style: TextStyle(
                  fontSize: 12,
                  color: expired ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
