import 'package:shared/models/report_model.dart';

/// Abstract repository for reports.
abstract class ReportRepository {
  /// Gets all reports for a device.
  Future<List<ReportModel>> getReports(String deviceId);

  /// Gets reports filtered by type.
  Future<List<ReportModel>> getReportsByType(String deviceId, ReportType type);

  /// Gets a specific report by ID.
  Future<ReportModel?> getReport(String deviceId, String reportId);
}
