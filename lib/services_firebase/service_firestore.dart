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
  }) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> map = {
      memberIdKey: member.id,
      likesKey: [],
      dateKey: date,
      textKey: text,
    };

    if (image != null) {
      final url = await ServiceStorage().addImage(
        file: File(image.path),
        folder: postCollectionKey,
        userId: member.id,
        imageName: date.toString(),
      );
      map[postImageKey] = url;
      firestorePost.doc().set(map);
    } else {
      firestorePost.doc().set(map);
    }
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
  addComment({required Post post, required String text}) {
    final memberId = ServiceAuthentification().myId;
    if (memberId == null) return;
    Map<String, dynamic> map = {
      memberIdKey: memberId,
      dateKey: DateTime.now().millisecondsSinceEpoch,
      textKey: text,
    };
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
}
