// lib/core/utils/chat_utils.dart

/// Deterministically generates a chat document ID from two UIDs.
/// Always sorted so [uidA, uidB] and [uidB, uidA] produce the same ID.
String generateChatId(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
