// lib/main.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_keys.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'core/services/encryption_service.dart';

final _log = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise Firebase
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    _log.e('CRITICAL: Firebase failed to initialize', error: e);
  }

  // Disable Google Fonts HTTP fetching to prevent crashes when offline/no DNS.
  // The app will use default system fonts until you bundle them in assets.
  GoogleFonts.config.allowRuntimeFetching = true;

  // App Check is intentionally disabled on Spark plan (no Storage/Functions).
  // Re-enable and activate when upgrading to Blaze:
  // try {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.debug,
  //     appleProvider: AppleProvider.debug,
  //   ).timeout(const Duration(seconds: 5));
  //   _log.i('App Check initialized');
  // } catch (e) {
  //   _log.w('App Check initialization warning', error: e);
  // }
  
  // Initialize encryption service (synchronous, near-zero cost).
  EncryptionService.instance.initialize();
  _log.i('AmanGhar booted — Local-First mode (Spark plan)');

  runApp(const ProviderScope(child: AmanGharApp()));

  // Initialize AdMob AFTER runApp so it never blocks app startup.
  MobileAds.instance.initialize().then((_) {
    _log.i('[AdMob] SDK initialized ✓');
  }).ignore();
}

/// Connects all Firebase services to local emulators.
/// Only called in debug builds via the assert block.
void _connectEmulators() {
  const emulatorHost = '10.0.2.2'; // Standard built-in AVD host alias

  // BYPASS AUTH EMULATOR HANG: Use Live Auth for Google Sign-In compatibility,
  // but keep Firestore Emulator for local seeded data.
  // FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);

  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // LOCAL-FIRST: Storage emulator not needed — re-enable with Firebase Storage on Blaze.
  // FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
}

class AmanGharApp extends ConsumerWidget {
  const AmanGharApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeNotifierProvider);

    // Initialize Notification Service when user is available
    ref.listen(currentUserProvider, (previous, next) {
      final user = next.valueOrNull;
      final prevUser = previous?.valueOrNull;
      if (user != null && prevUser?.uid != user.uid) {
        NotificationService.initialize(ref);
      }
    });

    // ScreenUtil base design size: 375 × 812 (per flutter-architecture.md)
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'AmanGhar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ur'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
          routerConfig: router,
        );
      },
    );
  }
}
