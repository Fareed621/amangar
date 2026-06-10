// lib/features/chat/domain/chat_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/message_model.dart';
import '../data/chat_repository_impl.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChat({
    required String currentUid,
    required String otherUid,
    required String currentName,
    required String otherName,
    required String? currentPhoto,
    required String? otherPhoto,
    String? bookingId,
  });

  Stream<List<ChatModel>> getChatList(String uid);

  Stream<List<MessageModel>> getMessages(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    String? mediaUrl,
  });

  Future<void> markMessagesAsRead({
    required String chatId,
    required List<String> messageIds,
  });
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});
