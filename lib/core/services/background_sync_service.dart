// lib/core/services/background_sync_service.dart
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

// ── LAYER 3: Background Task & Services ──────────────────────────────────────
//
// Android's WorkManager (via the `workmanager` Flutter plugin) runs tasks in a
// completely fresh Dart Isolate — no shared memory with the main UI isolate.
//
// The callbackDispatcher MUST be:
//  1. A top-level function (not a class method or closure).
//  2. Annotated with @pragma('vm:entry-point') so the Dart AOT compiler keeps
//     it alive and the OS can locate it when spawning the daemon isolate.
//
// Task identity:
//  • uniqueName  : 'amanghar_bg_sync'   — idempotency key (one task per name)
//  • taskName    : 'AmanGhar_Background_Sync' — human-readable label in logcat
//  • frequency   : Duration(minutes: 15) — minimum allowed by Android OS
//
// The task simulates a quiet cache-warmup / FCM token refresh without
// touching any UI state or Riverpod providers (those don't exist in this
// background isolate — they live only in the main isolate's memory).
// ─────────────────────────────────────────────────────────────────────────────

/// The entry-point function called by the OS daemon Isolate.
/// Must be top-level and annotated so AOT compilation keeps it alive.
@pragma('vm:entry-point')
void callbackDispatcher() {
  // Initialise Workmanager inside the background isolate.
  Workmanager().executeTask((taskName, inputData) async {
    // Create a fresh Logger instance — this runs in a background isolate,
    // so we cannot access the main isolate's InMemoryLogOutput singleton.
    // Logs appear in the Android logcat under the 'flutter' tag.
    final log = Logger();

    log.i('[BGSync] ▶ Task fired: $taskName');

    try {
      // ── Simulated background work ──────────────────────────────────────────
      // In production this would:
      //  a) Read the cached FCM token from SharedPreferences.
      //  b) Validate / refresh it against the Firebase Messaging API.
      //  c) Write updated timestamps back to SharedPreferences.
      //
      // Here we perform a deterministic no-op to prove execution reaches this
      // isolate — visible in logcat and (on main isolate) in the DevConsole
      // the next time the app foregrounds and re-reads shared prefs.
      await Future.delayed(const Duration(milliseconds: 500));
      log.i('[BGSync] ✓ Cache-token refresh simulation complete.');
      // ───────────────────────────────────────────────────────────────────────

      return Future.value(true); // SUCCESS — WorkManager will not reschedule
    } catch (e, st) {
      log.e('[BGSync] ✗ Task failed', error: e, stackTrace: st);
      return Future.value(false); // FAILURE — WorkManager may retry
    }
  });
}

/// Manages periodic background task registration for AmanGhar.
///
/// Call [BackgroundSyncService.initialize()] once in [main()] — it is
/// idempotent and safe to call on every cold start.
class BackgroundSyncService {
  BackgroundSyncService._(); // Prevent instantiation — static API only.

  static final _log = Logger();

  /// Registers the periodic WorkManager task with the Android OS scheduler.
  ///
  /// Safe to call on every app launch — WorkManager de-duplicates tasks by
  /// [uniqueName]; an existing task is replaced with [ExistingWorkPolicy.keep]
  /// so we never stack duplicate tasks.
  static Future<void> initialize() async {
    try {
      // Step 1: Hand the OS our top-level callback dispatcher.
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // set true to see WorkManager toasts on device
      );

      // Step 2: Register the recurring task.
      await Workmanager().registerPeriodicTask(
        'amanghar_bg_sync',           // uniqueName — de-duplication key
        'AmanGhar_Background_Sync',   // taskName — appears in logcat / DevConsole
        frequency: const Duration(minutes: 15), // minimum OS-allowed interval
        existingWorkPolicy: ExistingWorkPolicy.keep, // don't overwrite a live task
        constraints: Constraints(
          networkType: NetworkType.connected, // only run when online
        ),
      );

      _log.i('[BGSync] Periodic background task registered ✓ (every 15 min)');
    } catch (e, st) {
      // Non-fatal: the app works perfectly without background sync.
      _log.w('[BGSync] Registration failed — background sync disabled', error: e, stackTrace: st);
    }
  }
}
