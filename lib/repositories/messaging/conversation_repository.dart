import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationRepository {
  final FirebaseFirestore firestore;

  ConversationRepository({required this.firestore});

  //Creates a new conversation or returns existing one between two users
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    //Check if conversation already exists between these two users
    final existing = await firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id; // conversation already exists, return its ID
      }
    }

    //if no existing conversation, create a new one
    final docRef = firestore.collection('conversations').doc();
    await docRef.set({
      'conversationId': docRef.id,
      'participants': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}