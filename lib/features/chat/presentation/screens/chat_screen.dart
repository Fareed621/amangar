// lib/features/chat/presentation/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/chat_list_provider.dart';
import '../../../../core/models/message_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherName;
  final String otherUid;
  final String? otherPhoto;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherName,
    required this.otherUid,
    this.otherPhoto,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatActionsProvider).sendMessage(
          chatId: widget.chatId,
          text: text,
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final user = ref.watch(authStateProvider).valueOrNull;

    // Mark messages as read when the list updates
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundImage: widget.otherPhoto != null
                  ? NetworkImage(widget.otherPhoto!)
                  : null,
              child: widget.otherPhoto == null
                  ? Text(widget.otherName[0].toUpperCase())
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                widget.otherName,
                style: TextStyle(fontSize: 18.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              final target = UserModel(
                id: '',
                uid: widget.otherUid,
                name: widget.otherName,
                email: '',
                profilePhoto: widget.otherPhoto,
                role: 'provider',
                isVerified: false,
                rating: 0,
                totalReviews: 0,
                isBanned: false,
                isAdmin: false,
                isDeleted: false,
                isOnline: false,
                onboardingComplete: true,
                notificationSettings: const {},
                schemaVersion: 1,
              );
              showReportBottomSheet(context, target, chatId: widget.chatId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Side effect: Mark as read
                if (messages.isNotEmpty || widget.chatId.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(chatActionsProvider).markMessagesAsRead(
                          chatId: widget.chatId,
                          messages: messages,
                        );
                  });
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      context.l10n.sayHiTo(widget.otherName),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true, // Newest at bottom
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == user?.uid;

                    return _buildMessageBubble(message, isMine);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMine) {
    final timeString = message.timestamp != null
        ? DateFormat.jm().format(message.timestamp!.toDate())
        : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isMine ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(12.r).copyWith(
            bottomRight: isMine ? Radius.zero : Radius.circular(12.r),
            bottomLeft: !isMine ? Radius.zero : Radius.circular(12.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14.sp,
                    color: message.isRead ? Colors.blue : Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      color: Colors.grey[200],
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: context.l10n.typeMessageHint,
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                      onPressed: () {
                        // TODO: Implement media upload
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 24.r,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.send, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
