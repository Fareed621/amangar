import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/earnings_ledger_model.dart';
import '../../../../core/models/withdrawal_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/earnings_repository_impl.dart';
import '../../domain/earnings_repository.dart';

part 'earnings_provider.g.dart';

@riverpod
EarningsRepository earningsRepository(EarningsRepositoryRef ref) =>
    EarningsRepositoryImpl();

// ── Ledger (paginated) ────────────────────────────────────────────────────

class LedgerState {
  final List<EarningsLedgerModel> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DocumentSnapshot? lastDoc;

  const LedgerState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastDoc,
  });

  LedgerState copyWith({
    List<EarningsLedgerModel>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDoc,
  }) =>
      LedgerState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        lastDoc: lastDoc ?? this.lastDoc,
      );
}

@riverpod
class EarningsLedgerNotifier extends _$EarningsLedgerNotifier {
  static const _pageSize = 20;

  @override
  LedgerState build() {
    Future.microtask(loadPage);
    return const LedgerState(isLoading: true);
  }

  Future<void> loadPage() async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(earningsRepositoryProvider);
      final items = await repo.getLedger(uid, limit: _pageSize);
      state = LedgerState(
        items: items,
        isLoading: false,
        hasMore: items.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(earningsRepositoryProvider);
      final newItems = await repo.getLedger(uid, startAfter: state.lastDoc, limit: _pageSize);
      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── Withdrawals stream ─────────────────────────────────────────────────────

@riverpod
Stream<List<WithdrawalModel>> withdrawals(WithdrawalsRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return ref.read(earningsRepositoryProvider).getWithdrawals(uid);
}

// ── Withdrawal submit notifier ─────────────────────────────────────────────

class WithdrawalState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  const WithdrawalState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });
  WithdrawalState copyWith({bool? isSubmitting, bool? isSuccess, String? error}) =>
      WithdrawalState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error,
      );
}

@riverpod
class WithdrawalNotifier extends _$WithdrawalNotifier {
  @override
  WithdrawalState build() => const WithdrawalState();

  Future<void> submit(WithdrawalModel withdrawal) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await ref.read(earningsRepositoryProvider).submitWithdrawal(withdrawal);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      ref.invalidate(withdrawalsProvider);
      ref.invalidate(earningsLedgerNotifierProvider);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}
