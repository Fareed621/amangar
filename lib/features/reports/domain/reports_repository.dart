import '../../../core/models/report_model.dart';

abstract class ReportsRepository {
  Future<void> submitReport(ReportModel report);
  Future<void> blockUser({
    required String myUid,
    required String targetUid,
    required String targetName,
  });
}
