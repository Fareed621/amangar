import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/date_override_model.dart';
import '../../../../core/models/weekly_template_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../availability/data/availability_repository_impl.dart';
import '../../../availability/domain/availability_repository.dart';

part 'availability_notifier.g.dart';

@riverpod
AvailabilityRepository availabilityRepository(AvailabilityRepositoryRef ref) =>
    AvailabilityRepositoryImpl();

class AvailabilityState {
  final WeeklyTemplateModel? template;
  final List<DateOverrideModel> dateOverrides;
  final DateTime viewMonth;
  final bool isLoading;
  final bool isSaving;
  final bool isDirty;
  final String? error;

  const AvailabilityState({
    this.template,
    this.dateOverrides = const [],
    required this.viewMonth,
    this.isLoading = false,
    this.isSaving = false,
    this.isDirty = false,
    this.error,
  });

  AvailabilityState copyWith({
    WeeklyTemplateModel? template,
    List<DateOverrideModel>? dateOverrides,
    DateTime? viewMonth,
    bool? isLoading,
    bool? isSaving,
    bool? isDirty,
    String? error,
  }) =>
      AvailabilityState(
        template: template ?? this.template,
        dateOverrides: dateOverrides ?? this.dateOverrides,
        viewMonth: viewMonth ?? this.viewMonth,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        isDirty: isDirty ?? this.isDirty,
        error: error,
      );
}

@riverpod
class AvailabilityNotifier extends _$AvailabilityNotifier {
  static const _defaultDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  @override
  AvailabilityState build() {
    final now = DateTime.now();
    Future.microtask(load);
    return AvailabilityState(viewMonth: DateTime(now.year, now.month, 1));
  }

  Future<void> load() async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(availabilityRepositoryProvider);
      final template = await repo.getWeeklyTemplate(uid);
      final overrides = await repo.getDateOverrides(uid, state.viewMonth);

      // Build default template if none exists
      final effective = template ??
          WeeklyTemplateModel(
            template: Map.fromEntries(
              _defaultDays.map((d) => MapEntry(
                    d,
                    const DayTemplate(isAvailable: true, startTime: '09:00', endTime: '17:00'),
                  )),
            ),
          );

      state = state.copyWith(
        template: effective,
        dateOverrides: overrides,
        isLoading: false,
        isDirty: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> changeMonth(DateTime month) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = state.copyWith(viewMonth: DateTime(month.year, month.month, 1), isLoading: true);
    try {
      final overrides = await ref.read(availabilityRepositoryProvider).getDateOverrides(uid, state.viewMonth);
      state = state.copyWith(dateOverrides: overrides, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleDay(String dayKey, bool isAvailable) {
    if (state.template == null) return;
    final current = state.template!.template[dayKey] ?? const DayTemplate(isAvailable: false);
    final updated = Map<String, DayTemplate>.from(state.template!.template)
      ..[dayKey] = DayTemplate(
          isAvailable: isAvailable,
          startTime: current.startTime ?? '09:00',
          endTime: current.endTime ?? '17:00');
    state = state.copyWith(
      template: WeeklyTemplateModel(template: updated),
      isDirty: true,
    );
  }

  void updateDayTime(String dayKey, {String? startTime, String? endTime}) {
    if (state.template == null) return;
    final current = state.template!.template[dayKey] ?? const DayTemplate(isAvailable: true);
    final updated = Map<String, DayTemplate>.from(state.template!.template)
      ..[dayKey] = DayTemplate(
          isAvailable: current.isAvailable,
          startTime: startTime ?? current.startTime,
          endTime: endTime ?? current.endTime);
    state = state.copyWith(
      template: WeeklyTemplateModel(template: updated),
      isDirty: true,
    );
  }

  Future<void> saveTemplate() async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null || state.template == null) return;
    state = state.copyWith(isSaving: true);
    try {
      await ref.read(availabilityRepositoryProvider).saveWeeklyTemplate(
            uid,
            state.template!.template.map((k, v) => MapEntry(k, v.toMap())),
          );
      state = state.copyWith(isSaving: false, isDirty: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> toggleDateOverride(DateTime date) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    final normalized = DateTime(date.year, date.month, date.day);
    final repo = ref.read(availabilityRepositoryProvider);

    // Check if already overridden
    final existing = state.dateOverrides.where(
      (o) {
        final d = o.date.toDate();
        return DateTime(d.year, d.month, d.day) == normalized;
      },
    ).firstOrNull;

    try {
      if (existing != null) {
        // Toggle: if blocked → delete override (restore template). if unblocked → delete too.
        await repo.deleteDateOverride(uid, normalized);
      } else {
        // Block it
        await repo.setDateOverride(uid, normalized, true);
      }
      // Reload overrides
      final overrides = await repo.getDateOverrides(uid, state.viewMonth);
      state = state.copyWith(dateOverrides: overrides);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
