import 'package:shared/models/report_model.dart';
import 'package:shared/services/firestore_service.dart';
import 'package:shared/utils/logger.dart';
import '../../domain/repositories/report_repository.dart';

/// Implementation of [ReportRepository] using Firestore.
class ReportRepositoryImpl implements ReportRepository {
  final FirestoreService _firestoreService;

  ReportRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<ReportModel>> getReports(String deviceId) async {
    try {
      return await _firestoreService.getReportsByDevice(deviceId);
    } catch (e, st) {
      AppLogger.e('ReportRepo', 'Failed to get reports', e, st);
      return [];
    }
  }

  @override
  Future<List<ReportModel>> getReportsByType(
      String deviceId, ReportType type) async {
    try {
      return await _firestoreService.getReportsByType(deviceId, type);
    } catch (e, st) {
      AppLogger.e('ReportRepo', 'Failed to get reports by type', e, st);
      return [];
    }
  }

  @override
  Future<ReportModel?> getReport(String deviceId, String reportId) async {
    try {
      final reports = await _firestoreService.getReportsByDevice(deviceId);
      return reports.where((r) => r.id == reportId).firstOrNull;
    } catch (e, st) {
      AppLogger.e('ReportRepo', 'Failed to get report', e, st);
      return null;
    }
  }
}
