// lib/features/chat/data/chat_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/message_model.dart';
import '../domain/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateChatId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Future<String> getOrCreateChat({
    required String currentUid,
    required String otherUid,
    required String currentName,
    required String otherName,
    required String? currentPhoto,
    required String? otherPhoto,
    String? bookingId,
  }) async {
    final chatId = _generateChatId(currentUid, otherUid);
    await _firestore.doc('chats/$chatId').set({
      'participants': [currentUid, otherUid],
      'participantNames': {currentUid: currentName, otherUid: otherName},
      'participantPhotos': {currentUid: currentPhoto, otherUid: otherPhoto},
      'lastMessage': null,
      'lastMessageAt': null,
      'lastMessageSenderId': null,
      'unreadCount': {currentUid: 0, otherUid: 0},
      'relatedBookingId': bookingId,
      'isActive': true,
      'blockedBy': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return chatId;
  }

  @override
  Stream<List<ChatModel>> getChatList(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatModel.fromFirestore).toList());
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromFirestore).toList());
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    String? mediaUrl,
  }) async {
    final batch = _firestore.batch();

    // 1. Add the message
    final msgRef = _firestore.collection('chats/$chatId/messages').doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'text': text.trim(),
      'type': type,
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'readAt': null,
    });

    // 2. Update parent chat document
    final chatRef = _firestore.doc('chats/$chatId');
    final chatDoc = await chatRef.get();

    if (chatDoc.exists) {
      final participants =
          List<String>.from(chatDoc.get('participants') as List);
      final receiverId = participants.firstWhere((id) => id != senderId);

      batch.update(chatRef, {
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      // 3. Add to notifications collection for the receiver
      final participantNames =
          Map<String, dynamic>.from(chatDoc.get('participantNames') as Map);
      final senderName = participantNames[senderId] as String? ?? 'Someone';
      final notificationRef = _firestore.collection('notifications').doc();
      
      batch.set(notificationRef, {
        'userId': receiverId,
        'type': 'new_message',
        'title': senderName,
        'body': text.trim(),
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'actionScreen': 'chat',
        'actionParams': {'chatId': chatId},
        'isRead': false,
        'fcmSent': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required List<String> messageIds,
  }) async {
    final user = _firestore.app.options.projectId; // Just a placeholder check
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final batch = _firestore.batch();

    // 1. Mark individual messages
    for (final msgId in messageIds) {
      final docRef = _firestore.doc('chats/$chatId/messages/$msgId');
      batch.update(docRef, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    // 2. Reset the unread counter in the parent chat for THIS user
    final chatRef = _firestore.doc('chats/$chatId');
    batch.update(chatRef, {
      'unreadCount.$currentUid': 0,
    });

    await batch.commit();
  }
}
