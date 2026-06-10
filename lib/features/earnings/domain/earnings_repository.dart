import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/earnings_ledger_model.dart';
import '../../../../core/models/withdrawal_model.dart';

abstract class EarningsRepository {
  Future<List<EarningsLedgerModel>> getLedger(
    String uid, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  });

  Stream<List<WithdrawalModel>> getWithdrawals(String uid);

  Future<void> submitWithdrawal(WithdrawalModel withdrawal);
}
