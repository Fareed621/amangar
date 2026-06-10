// lib/features/chat/presentation/providers/chat_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/message_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../domain/chat_repository.dart';

final chatListProvider = StreamProvider.autoDispose<List<ChatModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return Stream.value([]);
  }

  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatList(user.uid);
});

final chatMessagesProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessages(chatId);
});

final chatActionsProvider = Provider<ChatActions>((ref) {
  return ChatActions(ref);
});

class ChatActions {
  final Ref _ref;
  ChatActions(this._ref);

  Future<String> createOrGetChat({
    required String otherUid,
    required String currentName,
    required String otherName,
    required String? currentPhoto,
    required String? otherPhoto,
    String? bookingId,
  }) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) throw Exception('User not logged in');

    final repo = _ref.read(chatRepositoryProvider);
    return repo.getOrCreateChat(
      currentUid: user.uid,
      otherUid: otherUid,
      currentName: currentName,
      otherName: otherName,
      currentPhoto: currentPhoto,
      otherPhoto: otherPhoto,
      bookingId: bookingId,
    );
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String type = 'text',
    String? mediaUrl,
  }) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) throw Exception('User not logged in');

    final repo = _ref.read(chatRepositoryProvider);
    await repo.sendMessage(
      chatId: chatId,
      senderId: user.uid,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
    );
  }

  Future<void> markMessagesAsRead({
    required String chatId,
    required List<MessageModel> messages,
  }) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final unreadMessages = messages
        .where((m) => m.senderId != user.uid && !m.isRead)
        .map((m) => m.id)
        .toList();

    final repo = _ref.read(chatRepositoryProvider);
    await repo.markMessagesAsRead(chatId: chatId, messageIds: unreadMessages);
  }
}
