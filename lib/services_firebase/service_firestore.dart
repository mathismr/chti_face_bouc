import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../modeles/constantes.dart';
import '../modeles/membre.dart';
import '../modeles/post.dart';
import 'service_authentification.dart';
import 'service_storage.dart';

class ServiceFirestore {
  // Acces a la BDD
  static final instance = FirebaseFirestore.instance;

  // Acces specifique aux collections
  final firestoreMember = instance.collection(memberCollectionKey);
  final firestorePost = instance.collection(postCollectionKey);

  // Ajouter un membre
  addMember({required String id, required Map<String, dynamic> data}) {
    firestoreMember.doc(id).set(data);
  }

  // Mettre a jour un membre
  updateMember({required String id, required Map<String, dynamic> data}) {
    firestoreMember.doc(id).update(data);
  }

  // Stockage et mise a jour d'une image
  updateImage({
    required File file,
    required String folder,
    required String memberId,
    required String imageName,
  }) {
    ServiceStorage()
        .addImage(
            file: file,
            folder: folder,
            userId: memberId,
            imageName: imageName)
        .then((imageUrl) {
      updateMember(id: memberId, data: {imageName: imageUrl});
    });
  }

  // Recuperer un membre specifique
  specificMember(String id) {
    return firestoreMember.doc(id).snapshots();
  }

  // Lire la liste de tous les membres
  allMembers() => firestoreMember.snapshots();

  // Lire la liste de tous les posts
  allPosts() =>
      firestorePost.orderBy(dateKey, descending: true).snapshots();

  // Lire des posts d'un utilisateur
  postForMember(String id) => firestorePost
      .where(memberIdKey, isEqualTo: id)
      .orderBy(dateKey, descending: true)
      .snapshots();

  // Creer un post
  createPost({
    required Membre member,
    required String text,
    required XFile? image,
    String? gifUrl,
    String? pollQuestion,
    List<String>? pollOptions,
    int? pollDeadlineDays,
  }) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> map = {
      memberIdKey: member.id,
      likesKey: [],
      dateKey: date,
      textKey: text,
    };

    // Sondage
    if (pollQuestion != null && pollQuestion.isNotEmpty && pollOptions != null && pollOptions.isNotEmpty) {
      final deadline = DateTime.now()
          .add(Duration(days: pollDeadlineDays ?? 1))
          .millisecondsSinceEpoch;
      Map<String, List<String>> votes = {};
      for (var option in pollOptions) {
        votes[option] = [];
      }
      map[pollQuestionKey] = pollQuestion;
      map[pollDeadlineKey] = deadline;
      map[pollOptionsKey] = pollOptions;
      map[pollVotesKey] = votes;
    }

    if (gifUrl != null && gifUrl.isNotEmpty) {
      map[gifUrlKey] = gifUrl;
    }

    if (image != null) {
      final url = await ServiceStorage().addImage(
        file: File(image.path),
        folder: postCollectionKey,
        userId: member.id,
        imageName: date.toString(),
      );
      map[postImageKey] = url;
    }

    firestorePost.doc().set(map);
  }

  // Voter sur un sondage
  votePoll({required Post post, required String option, required String userId}) {
    final votes = post.pollVotes;
    // Retirer le vote precedent
    for (var key in votes.keys) {
      if (votes[key]!.contains(userId)) {
        post.reference.update({
          '$pollVotesKey.$key': FieldValue.arrayRemove([userId])
        });
      }
    }
    // Ajouter le nouveau vote
    post.reference.update({
      '$pollVotesKey.$option': FieldValue.arrayUnion([userId])
    });
  }

  // Supprimer un post
  deletePost({required Post post}) async {
    // Supprimer les commentaires du post
    final comments = await post.reference.collection(commentCollectionKey).get();
    for (var comment in comments.docs) {
      await comment.reference.delete();
    }
    // Supprimer le post
    await post.reference.delete();
  }

  // Ajouter un "j'aime" sur le post
  addLike({required String memberID, required Post post}) {
    if (post.likes.contains(memberID)) {
      post.reference.update({
        likesKey: FieldValue.arrayRemove([memberID])
      });
    } else {
      post.reference.update({
        likesKey: FieldValue.arrayUnion([memberID])
      });
    }
  }

  // Ajouter un commentaire sur un post
  addComment({required Post post, required String text, String? gifUrl}) {
    final memberId = ServiceAuthentification().myId;
    if (memberId == null) return;
    Map<String, dynamic> map = {
      memberIdKey: memberId,
      dateKey: DateTime.now().millisecondsSinceEpoch,
      textKey: text,
    };
    if (gifUrl != null && gifUrl.isNotEmpty) {
      map[gifUrlKey] = gifUrl;
    }
    post.reference.collection(commentCollectionKey).doc().set(map);
  }

  // Lire un commentaire sur un post
  postComment(String postId) => firestorePost
      .doc(postId)
      .collection(commentCollectionKey)
      .orderBy(dateKey, descending: true)
      .snapshots();

  // Envoyer une notification
  sendNotification(
      {required String to,
      required String text,
      required String postID}) {
    final memberId = ServiceAuthentification().myId;
    if (memberId == null) return;
    Map<String, dynamic> map = {
      dateKey: DateTime.now().millisecondsSinceEpoch,
      isReadKey: false,
      fromKey: memberId,
      textKey: text,
      postIdKey: postID,
    };
    firestoreMember.doc(to).collection(notificationCollectionKey).doc().set(map);
  }

  // Marquer une notification qu a ete lue
  markRead(DocumentReference reference) {
    reference.update({isReadKey: true});
  }

  // Liste des notifications pour un membre
  notificationForUser(String id) {
    return firestoreMember
        .doc(id)
        .collection(notificationCollectionKey)
        .orderBy(dateKey, descending: true)
        .snapshots();
  }

  // --- Conversations & Messages ---

  final firestoreConversation = instance.collection(conversationCollectionKey);

  // Recuperer ou creer une conversation entre deux membres
  Future<DocumentReference> getOrCreateConversation(
      String memberId1, String memberId2) async {
    final participants = [memberId1, memberId2]..sort();
    final query = await firestoreConversation
        .where(participantsKey, isEqualTo: participants)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.reference;
    }
    final doc = firestoreConversation.doc();
    await doc.set({
      participantsKey: participants,
      lastMessageKey: "",
      lastMessageDateKey: 0,
    });
    return doc;
  }

  // Lire les conversations d'un membre
  Stream<QuerySnapshot> conversationsForMember(String memberId) {
    return firestoreConversation
        .where(participantsKey, arrayContains: memberId)
        .orderBy(lastMessageDateKey, descending: true)
        .snapshots();
  }

  // Envoyer un message dans une conversation
  sendMessage({
    required DocumentReference conversationRef,
    required String senderId,
    required String text,
    String? gifUrl,
  }) {
    final date = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> messageData = {
      senderIdKey: senderId,
      textKey: text,
      dateKey: date,
    };
    if (gifUrl != null && gifUrl.isNotEmpty) {
      messageData[gifUrlKey] = gifUrl;
    }
    conversationRef.collection(messageCollectionKey).doc().set(messageData);
    conversationRef.update({
      lastMessageKey: text.isNotEmpty ? text : '🎬 GIF',
      lastMessageDateKey: date,
    });
  }

  // Lire les messages d'une conversation
  Stream<QuerySnapshot> messagesForConversation(DocumentReference conversationRef) {
    return conversationRef
        .collection(messageCollectionKey)
        .orderBy(dateKey, descending: false)
        .snapshots();
  }
}
