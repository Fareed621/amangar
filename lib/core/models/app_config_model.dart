// lib/core/models/app_config_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppConfigGlobalModel extends Equatable {
  const AppConfigGlobalModel({
    required this.cities,
    required this.maxFavoritesPerHirer,
    required this.minWithdrawalAmount,
    required this.maxBookingDaysAhead,
    required this.maxRecurringBookingDays,
    required this.messageLengthLimit,
    required this.notesLengthLimit,
    required this.bioLengthLimit,
    required this.commentLengthLimit,
    required this.minFullTimeRate,
    required this.maxFullTimeRate,
    required this.minPartTimeRate,
    required this.maxPartTimeRate,
    required this.features,
  });

  final List<String> cities;
  final int maxFavoritesPerHirer;
  final int minWithdrawalAmount;
  final int maxBookingDaysAhead;
  final int maxRecurringBookingDays;
  final int messageLengthLimit;
  final int notesLengthLimit;
  final int bioLengthLimit;
  final int commentLengthLimit;
  final int minFullTimeRate;
  final int maxFullTimeRate;
  final int minPartTimeRate;
  final int maxPartTimeRate;
  final Map<String, dynamic> features;

  factory AppConfigGlobalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppConfigGlobalModel(
      cities: List<String>.from(data['cities'] as List? ?? []),
      maxFavoritesPerHirer: data['maxFavoritesPerHirer'] as int? ?? 10,
      minWithdrawalAmount: data['minWithdrawalAmount'] as int? ?? 500,
      maxBookingDaysAhead: data['maxBookingDaysAhead'] as int? ?? 31,
      maxRecurringBookingDays: data['maxRecurringBookingDays'] as int? ?? 31,
      messageLengthLimit: data['messageLengthLimit'] as int? ?? 1000,
      notesLengthLimit: data['notesLengthLimit'] as int? ?? 200,
      bioLengthLimit: data['bioLengthLimit'] as int? ?? 500,
      commentLengthLimit: data['commentLengthLimit'] as int? ?? 300,
      minFullTimeRate: data['minFullTimeRate'] as int? ?? 5000,
      maxFullTimeRate: data['maxFullTimeRate'] as int? ?? 100000,
      minPartTimeRate: data['minPartTimeRate'] as int? ?? 100,
      maxPartTimeRate: data['maxPartTimeRate'] as int? ?? 2000,
      features: data['features'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toFirestore() => {
        'cities': cities,
        'maxFavoritesPerHirer': maxFavoritesPerHirer,
        'minWithdrawalAmount': minWithdrawalAmount,
        'maxBookingDaysAhead': maxBookingDaysAhead,
        'maxRecurringBookingDays': maxRecurringBookingDays,
        'messageLengthLimit': messageLengthLimit,
        'notesLengthLimit': notesLengthLimit,
        'bioLengthLimit': bioLengthLimit,
        'commentLengthLimit': commentLengthLimit,
        'minFullTimeRate': minFullTimeRate,
        'maxFullTimeRate': maxFullTimeRate,
        'minPartTimeRate': minPartTimeRate,
        'maxPartTimeRate': maxPartTimeRate,
        'features': features,
      };

  AppConfigGlobalModel copyWith({
    List<String>? cities, int? maxFavoritesPerHirer, int? minWithdrawalAmount,
    int? maxBookingDaysAhead, int? maxRecurringBookingDays,
    int? messageLengthLimit, int? notesLengthLimit, int? bioLengthLimit,
    int? commentLengthLimit, int? minFullTimeRate, int? maxFullTimeRate,
    int? minPartTimeRate, int? maxPartTimeRate, Map<String, dynamic>? features,
  }) =>
      AppConfigGlobalModel(
        cities: cities ?? this.cities,
        maxFavoritesPerHirer: maxFavoritesPerHirer ?? this.maxFavoritesPerHirer,
        minWithdrawalAmount: minWithdrawalAmount ?? this.minWithdrawalAmount,
        maxBookingDaysAhead: maxBookingDaysAhead ?? this.maxBookingDaysAhead,
        maxRecurringBookingDays: maxRecurringBookingDays ?? this.maxRecurringBookingDays,
        messageLengthLimit: messageLengthLimit ?? this.messageLengthLimit,
        notesLengthLimit: notesLengthLimit ?? this.notesLengthLimit,
        bioLengthLimit: bioLengthLimit ?? this.bioLengthLimit,
        commentLengthLimit: commentLengthLimit ?? this.commentLengthLimit,
        minFullTimeRate: minFullTimeRate ?? this.minFullTimeRate,
        maxFullTimeRate: maxFullTimeRate ?? this.maxFullTimeRate,
        minPartTimeRate: minPartTimeRate ?? this.minPartTimeRate,
        maxPartTimeRate: maxPartTimeRate ?? this.maxPartTimeRate,
        features: features ?? this.features,
      );

  @override
  List<Object?> get props => [
        cities, maxFavoritesPerHirer, minWithdrawalAmount, maxBookingDaysAhead,
        maxRecurringBookingDays, messageLengthLimit, notesLengthLimit,
        bioLengthLimit, commentLengthLimit, minFullTimeRate, maxFullTimeRate,
        minPartTimeRate, maxPartTimeRate, features,
      ];
}

class SkillTagsModel extends Equatable {
  const SkillTagsModel({
    required this.cookSkills,
    required this.maidSkills,
    required this.languages,
  });

  final List<String> cookSkills;
  final List<String> maidSkills;
  final List<String> languages;

  factory SkillTagsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SkillTagsModel(
      cookSkills: List<String>.from(data['cookSkills'] as List? ?? []),
      maidSkills: List<String>.from(data['maidSkills'] as List? ?? []),
      languages: List<String>.from(data['languages'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'cookSkills': cookSkills,
        'maidSkills': maidSkills,
        'languages': languages,
      };

  SkillTagsModel copyWith({
    List<String>? cookSkills,
    List<String>? maidSkills,
    List<String>? languages,
  }) =>
      SkillTagsModel(
        cookSkills: cookSkills ?? this.cookSkills,
        maidSkills: maidSkills ?? this.maidSkills,
        languages: languages ?? this.languages,
      );

  @override
  List<Object?> get props => [cookSkills, maidSkills, languages];
}
