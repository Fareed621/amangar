import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/earnings_ledger_model.dart';
import '../../../../core/models/withdrawal_model.dart';
import '../domain/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<EarningsLedgerModel>> getLedger(
    String uid, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(FirestorePaths.earningsLedger(uid))
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    return snap.docs.map((doc) => EarningsLedgerModel.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<WithdrawalModel>> getWithdrawals(String uid) {
    return _firestore
        .collection(FirestorePaths.withdrawals)
        .where('providerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WithdrawalModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> submitWithdrawal(WithdrawalModel withdrawal) async {
    final docRef = _firestore.collection(FirestorePaths.withdrawals).doc();
    final data = withdrawal.toFirestore();
    data['createdAt'] = Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    data['status'] = 'pending';
    data['id'] = docRef.id;

    final batch = _firestore.batch();

    // 1. Save withdrawal request
    batch.set(docRef, data);

    // 2. Write debit ledger entry so it shows in Transaction History
    final ledgerRef = _firestore
        .collection('users')
        .doc(withdrawal.providerId)
        .collection('earningsLedger')
        .doc();
    batch.set(ledgerRef, {
      'bookingId': 'withdrawal_${docRef.id}',
      'hirerName': 'Withdrawal (${withdrawal.method.toUpperCase()})',
      'serviceCategory': 'withdrawal',
      'serviceType': withdrawal.method,
      'amount': withdrawal.amount,
      'entryType': 'debit',
      'bookingDate': null,
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
  }
}
