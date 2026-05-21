import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Post {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Post({required this.reference, required this.id, required this.map});

  String get member => map[memberIdKey] ?? "";
  String get text => map[textKey] ?? "";
  String get imageUrl => map[postImageKey] ?? "";
  int get date => map[dateKey] ?? 0;
  List<dynamic> get likes => map[likesKey] ?? [];

  // Poll
  bool get hasPoll => map[pollQuestionKey] != null && map[pollQuestionKey].toString().isNotEmpty;
  String get pollQuestion => map[pollQuestionKey] ?? "";
  int get pollDeadline => map[pollDeadlineKey] ?? 0;
  List<String> get pollOptions =>
      (map[pollOptionsKey] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
  Map<String, List<String>> get pollVotes {
    final raw = map[pollVotesKey] as Map<String, dynamic>? ?? {};
    return raw.map((key, value) =>
        MapEntry(key, (value as List<dynamic>).map((e) => e.toString()).toList()));
  }

  bool get isPollExpired =>
      DateTime.now().millisecondsSinceEpoch > pollDeadline;

  int get totalVotes {
    int total = 0;
    for (var list in pollVotes.values) {
      total += list.length;
    }
    return total;
  }

  String? votedOption(String userId) {
    for (var entry in pollVotes.entries) {
      if (entry.value.contains(userId)) return entry.key;
    }
    return null;
  }
}
