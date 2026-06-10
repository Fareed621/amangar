// lib/core/constants/firestore_paths.dart

/// All Firestore collection and document paths.
/// Never type raw path strings in repositories — always use this class.
class FirestorePaths {
  FirestorePaths._();

  // ── Top-level collections ────────────────────────────────────────────────
  static const users          = 'users';
  static const bookings       = 'bookings';
  static const chats          = 'chats';
  static const ratings        = 'ratings';
  static const reports        = 'reports';
  static const withdrawals    = 'withdrawals';
  static const notifications  = 'notifications';
  static const appConfig      = 'appConfig';
  static const supportTickets = 'supportTickets';
  static const auditLogs      = 'auditLogs';

  // ── Document paths ───────────────────────────────────────────────────────
  static String user(String uid)            => '$users/$uid';
  static String providerProfile(String uid) => '$users/$uid/providerProfile/profile';
  static String weeklyTemplate(String uid)  => '$users/$uid/availability/weeklyTemplate';
  static String availabilityOverrides(String uid) => '$users/$uid/availability_overrides';
  static String availabilityOverride(String uid, String date) =>
      '$users/$uid/availability_overrides/$date';
  static String favorite(String uid, String providerId) =>
      '$users/$uid/favorites/$providerId';
  static String earningsLedger(String uid)  => '$users/$uid/earningsLedger';
  static String booking(String id)          => '$bookings/$id';
  static String chat(String id)             => '$chats/$id';

  // ── Sub-collection paths ─────────────────────────────────────────────────
  static String messages(String chatId)               => '$chats/$chatId/messages';
  static String message(String chatId, String msgId)  => '$chats/$chatId/messages/$msgId';
  static String notification(String id)               => '$notifications/$id';
  static String withdrawal(String id)                 => '$withdrawals/$id';
  static String rating(String id)                     => '$ratings/$id';
  static String report(String id)                     => '$reports/$id';

  // ── AppConfig documents ──────────────────────────────────────────────────
  static const appConfigGlobal    = 'appConfig/global';
  static const appConfigSkillTags = 'appConfig/skillTags';
}
