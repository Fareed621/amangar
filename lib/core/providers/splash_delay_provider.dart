import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_delay_provider.g.dart';

/// A simple provider that waits for a minimum duration (e.g. 2s)
/// to ensure the splash screen is visible and animations can play.
@riverpod
Future<void> splashDelay(SplashDelayRef ref) async {
  await Future.delayed(const Duration(seconds: 2));
}
