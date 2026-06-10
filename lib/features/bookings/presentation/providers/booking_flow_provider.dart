import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/provider_with_profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/availability_utils.dart';
import '../../data/bookings_repository_impl.dart';
import '../../domain/bookings_repository.dart';

part 'booking_flow_provider.g.dart';

@riverpod
BookingsRepository bookingsRepository(BookingsRepositoryRef ref) {
  return BookingsRepositoryImpl();
}

class BookingFlowState {
  final int currentStep;
  final bool isSubmitting;
  final bool isSuccess;
  final String? lastBookingId;
  final String? error;

  final String? providerId;
  final String? providerName;
  final String? providerPhoto;
  final String? providerPhone;
  final int? fullTimeRate;
  final int? partTimeRate;
  final String? serviceCategory;

  final String? hirerName;
  final String? hirerPhoto;

  final String serviceType;
  final List<DateTime> dates;
  final bool isRecurring;
  final List<String> recurringDays;
  final DateTime? recurringEndDate;
  final String startTime;
  final String endTime;
  final String? notes;

  final Map<String, dynamic>? priceBreakdown;
  final bool termsAccepted;

  const BookingFlowState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.lastBookingId,
    this.error,
    this.providerId,
    this.providerName,
    this.providerPhoto,
    this.providerPhone,
    this.fullTimeRate,
    this.partTimeRate,
    this.serviceCategory,
    this.hirerName,
    this.hirerPhoto,
    this.serviceType = 'full_time',
    this.dates = const [],
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    this.startTime = '09:00',
    this.endTime = '17:00',
    this.notes,
    this.priceBreakdown,
    this.termsAccepted = false,
  });

  int get computedPrice {
    if (fullTimeRate == null || partTimeRate == null) return 0;
    return calculateDisplayPrice(
      serviceType: serviceType,
      fullTimeRate: fullTimeRate!,
      partTimeRate: partTimeRate!,
      numberOfDays: dates.isEmpty ? 1 : dates.length,
      startTime: startTime,
      endTime: endTime,
    );
  }

  bool get canProceed {
    if (currentStep == 0)
      return true; // Always can proceed from service type if rate is there
    if (currentStep == 1) return dates.isNotEmpty;
    if (currentStep == 2) return true;
    return false;
  }

  bool get canSubmit {
    return currentStep == 3 &&
        termsAccepted &&
        !isSubmitting &&
        dates.isNotEmpty;
  }

  BookingFlowState copyWith({
    int? currentStep,
    bool? isSubmitting,
    bool? isSuccess,
    String? lastBookingId,
    String? error,
    String? providerId,
    String? providerName,
    String? providerPhoto,
    String? providerPhone,
    int? fullTimeRate,
    int? partTimeRate,
    String? serviceCategory,
    String? hirerName,
    String? hirerPhoto,
    String? serviceType,
    List<DateTime>? dates,
    bool? isRecurring,
    List<String>? recurringDays,
    DateTime? recurringEndDate,
    String? startTime,
    String? endTime,
    String? notes,
    Map<String, dynamic>? priceBreakdown,
    bool? termsAccepted,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      lastBookingId: lastBookingId ?? this.lastBookingId,
      error: error ?? this.error,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerPhoto: providerPhoto ?? this.providerPhoto,
      providerPhone: providerPhone ?? this.providerPhone,
      fullTimeRate: fullTimeRate ?? this.fullTimeRate,
      partTimeRate: partTimeRate ?? this.partTimeRate,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      hirerName: hirerName ?? this.hirerName,
      hirerPhoto: hirerPhoto ?? this.hirerPhoto,
      serviceType: serviceType ?? this.serviceType,
      dates: dates ?? this.dates,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}

@riverpod
class BookingFlow extends _$BookingFlow {
  @override
  BookingFlowState build() {
    return const BookingFlowState();
  }

  void initProvider(ProviderWithProfileModel provider) {
    final hirer = ref.read(currentUserProvider).valueOrNull;
    state = state.copyWith(
      providerId: provider.user.uid,
      providerName: provider.user.name,
      providerPhoto: provider.user.profilePhoto,
      providerPhone: provider.user.phone,
      fullTimeRate: provider.profile?.fullTimeRate,
      partTimeRate: provider.profile?.partTimeRate,
      serviceCategory: provider.profile?.serviceCategory,
      hirerName: hirer?.name,
      hirerPhoto: hirer?.profilePhoto,
    );
  }

  void setStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setServiceType(String type) => state = state.copyWith(serviceType: type);

  void setDates(List<DateTime> dates) => state = state.copyWith(dates: dates);

  void setRecurring(bool isRecurring) =>
      state = state.copyWith(isRecurring: isRecurring);

  void setRecurringDays(List<String> days) =>
      state = state.copyWith(recurringDays: days);

  void toggleRecurring(bool isRecurring) {
    if (isRecurring) {
      state = state.copyWith(isRecurring: true);
    } else {
      state = state.copyWith(
        isRecurring: false,
        recurringDays: [],
        recurringEndDate: DateTime.now().add(const Duration(days: 30)),
      );
    }
  }

  void setRecurringEndDate(DateTime date) =>
      state = state.copyWith(recurringEndDate: date);

  void setStartTime(String time) => state = state.copyWith(startTime: time);

  void setEndTime(String time) => state = state.copyWith(endTime: time);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void setTermsAccepted(bool accepted) =>
      state = state.copyWith(termsAccepted: accepted);

  Future<void> submit(BuildContext context) async {
    if (!state.canSubmit) return;
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = ref.read(bookingsRepositoryProvider);
      final hirerId = ref.read(currentUserProvider).valueOrNull?.uid;

      if (hirerId == null) throw Exception('Hirer not logged in');

      final booking = BookingModel(
        id: '', // Generated by repo
        hirerId: hirerId,
        providerId: state.providerId!,
        serviceType: state.serviceType,
        serviceCategory: state.serviceCategory ?? '',
        status: 'pending',
        dates: state.dates.map((d) => Timestamp.fromDate(d)).toList(),
        isRecurring: state.isRecurring,
        recurringDays: state.recurringDays,
        recurringStartDate: state.dates.isNotEmpty
            ? Timestamp.fromDate(state.dates.first)
            : null,
        recurringEndDate: state.recurringEndDate != null
            ? Timestamp.fromDate(state.recurringEndDate!)
            : null,
        startTime: state.startTime,
        endTime: state.endTime,
        totalDurationHours:
            calculateDurationHours(state.startTime, state.endTime),
        displayPrice: state.computedPrice,
        priceBreakdown: state.priceBreakdown ?? {},
        notes: state.notes,
        hirerName: state.hirerName ?? 'Unknown Hirer',
        hirerPhoto: state.hirerPhoto,
        providerName: state.providerName ?? 'Unknown Provider',
        providerPhoto: state.providerPhoto,
        providerPhone: state.providerPhone,
        hirerRated: false,
        providerRated: false,
        ratingReminderSent: false,
        reminderSent: false,
        hirerConfirmedPayment: false,
        providerConfirmedReceipt: false,
        schemaVersion: 2,
      );

      final bookingId = await repo.createBooking(booking);

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        lastBookingId: bookingId,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}
