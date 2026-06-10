// lib/core/providers/app_config_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../constants/firestore_paths.dart';
import '../models/app_config_model.dart';

part 'app_config_provider.g.dart';

final _log = Logger();

/// Fetches global app configuration from Firestore (one-time).
@riverpod
Future<AppConfigGlobalModel> appConfig(AppConfigRef ref) async {
  try {
    final snap = await FirebaseFirestore.instance
        .doc(FirestorePaths.appConfigGlobal)
        .get();
    if (snap.exists) {
      final config = AppConfigGlobalModel.fromFirestore(snap);
      if (config.cities.isNotEmpty) return config;
    }
  } catch (e) {
    _log.w('[AppConfig] Failed to fetch config from Firestore, using local fallback');
  }

  // LOCAL-FIRST: Fallback config for Spark plan / empty database
  return const AppConfigGlobalModel(
    cities: ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Peshawar'],
    maxFavoritesPerHirer: 10,
    minWithdrawalAmount: 1000,
    maxBookingDaysAhead: 30,
    maxRecurringBookingDays: 30,
    messageLengthLimit: 500,
    notesLengthLimit: 200,
    bioLengthLimit: 300,
    commentLengthLimit: 200,
    minFullTimeRate: 15000,
    maxFullTimeRate: 100000,
    minPartTimeRate: 5000,
    maxPartTimeRate: 50000,
    features: {},
  );
}

/// Fetches skill tags (cook skills, maid skills, languages) from Firestore.
@riverpod
Future<SkillTagsModel> skillTags(SkillTagsRef ref) async {
  try {
    final snap = await FirebaseFirestore.instance
        .doc(FirestorePaths.appConfigSkillTags)
        .get();
    if (snap.exists) {
      final tags = SkillTagsModel.fromFirestore(snap);
      if (tags.cookSkills.isNotEmpty || tags.maidSkills.isNotEmpty || tags.languages.isNotEmpty) {
        return tags;
      }
    }
  } catch (e) {
    _log.w('[AppConfig] Failed to fetch skill tags from Firestore, using local fallback');
  }

  // LOCAL-FIRST: Fallback skill tags
  return const SkillTagsModel(
    cookSkills: ['Desi', 'Continental', 'Baking', 'Chinese', 'BBQ'],
    maidSkills: ['Cleaning', 'Washing', 'Ironing', 'Babysitting', 'Cooking'],
    languages: ['Urdu', 'English', 'Punjabi', 'Pashto', 'Sindhi'],
  );
}
