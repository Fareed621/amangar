// lib/features/chat/presentation/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/chat_list_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chatsTitle, style: TextStyle(fontSize: 20.sp)),
      ),
      body: chatListAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noConversationsYet,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: chats.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1.h, indent: 70.w),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUid = chat.participants.firstWhere(
                (id) => id != user?.uid,
                orElse: () => chat.participants.first,
              );
              final otherName = chat.participantNames[otherUid] ?? 'Unknown';
              final otherPhoto = chat.participantPhotos[otherUid];
              final unreadCount = chat.unreadCount[user?.uid] ?? 0;
              final timeString = chat.lastMessageAt != null
                  ? DateFormat.jm().format(chat.lastMessageAt!.toDate())
                  : '';

              return ListTile(
                leading: CircleAvatar(
                  radius: 24.r,
                  backgroundImage:
                      otherPhoto != null ? NetworkImage(otherPhoto) : null,
                  child: otherPhoto == null
                      ? Text(otherName[0].toUpperCase())
                      : null,
                ),
                title: Text(
                  otherName,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chat.lastMessage ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    if (unreadCount > 0) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  context.push('/chat/${chat.id}', extra: {
                    'otherName': otherName,
                    'otherUid': otherUid,
                    'otherPhoto': otherPhoto,
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err', style: TextStyle(fontSize: 16.sp))),
      ),
    );
  }
}
