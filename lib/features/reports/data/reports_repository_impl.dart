import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/report_model.dart';
import '../domain/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepositoryImpl(this._firestore);

  @override
  Future<void> submitReport(ReportModel report) async {
    await _firestore
        .collection('reports')
        .add(report.toFirestore());
  }

  @override
  Future<void> blockUser({
    required String myUid,
    required String targetUid,
    required String targetName,
  }) async {
    await _firestore
        .collection('users')
        .doc(myUid)
        .collection('blockedUsers')
        .doc(targetUid)
        .set({
      'uid': targetUid,
      'name': targetName,
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }
}
