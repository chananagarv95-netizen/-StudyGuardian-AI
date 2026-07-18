import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/report_model.dart';
import 'package:shared/utils/logger.dart';

/// Service for exporting [ReportModel] data as PDF and CSV files.
///
/// Generates professionally formatted documents from aggregated report data
/// and shares them via the device's native share sheet using [share_plus].
/// Files are written to the temporary directory and cleaned up by the OS.
class ReportExportService {
  ReportExportService._();

  static const String _tag = 'ReportExportService';

  // ─── Color Constants ─────────────────────────────────────────────────────

  static const _indigo = PdfColor.fromInt(0xFF6366F1);
  static const _emerald = PdfColor.fromInt(0xFF10B981);
  static const _teal = PdfColor.fromInt(0xFF14B8A6);
  static const _amber = PdfColor.fromInt(0xFFF59E0B);
  static const _red = PdfColor.fromInt(0xFFEF4444);
  static const _slate800 = PdfColor.fromInt(0xFF1E293B);
  static const _slate700 = PdfColor.fromInt(0xFF334155);
  static const _slate50 = PdfColor.fromInt(0xFFF8FAFC);

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Generates a professionally formatted PDF report and opens the
  /// device share sheet so the user can send or save it.
  ///
  /// The PDF includes key metrics, score breakdown, top apps, and
  /// the AI-generated summary from [report.data].
  static Future<void> exportAndSharePdf(ReportModel report) async {
    try {
      AppLogger.i(_tag, 'Generating PDF for report ${report.id}');

      final pdf = pw.Document(
        title: 'StudyGuardian Report',
        author: 'StudyGuardian AI',
        creator: 'StudyGuardian AI',
      );

      final dateFormat = DateFormat('MMM dd, yyyy');
      final startDateStr = dateFormat.format(report.startDate);
      final endDateStr = dateFormat.format(report.endDate);
      final generatedAtStr =
          DateFormat('MMM dd, yyyy – hh:mm a').format(report.generatedAt);
      final data = report.data;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPdfHeader(
            report.type.displayName,
            startDateStr,
            endDateStr,
          ),
          footer: (context) => _buildPdfFooter(context, generatedAtStr),
          build: (context) => [
            pw.SizedBox(height: 20),

            // ── Key Metrics Table ──────────────────────────────────────
            _sectionTitle('Key Metrics'),
            pw.SizedBox(height: 8),
            _buildMetricsTable(data),
            pw.SizedBox(height: 24),

            // ── Score Breakdown ────────────────────────────────────────
            _sectionTitle('Score Breakdown'),
            pw.SizedBox(height: 8),
            _buildScoreBreakdown(data),
            pw.SizedBox(height: 24),

            // ── Top Apps ──────────────────────────────────────────────
            if (_getTopApps(data).isNotEmpty) ...[
              _sectionTitle('Top Apps'),
              pw.SizedBox(height: 8),
              _buildTopAppsTable(_getTopApps(data)),
              pw.SizedBox(height: 24),
            ],

            // ── AI Summary ────────────────────────────────────────────
            if ((data['summary'] as String?)?.isNotEmpty == true) ...[
              _sectionTitle('AI Summary'),
              pw.SizedBox(height: 8),
              _buildSummaryBlock(data['summary'] as String),
            ],
          ],
        ),
      );

      final file = await _writeTempFile(
        bytes: await pdf.save(),
        fileName: _buildFileName(report, 'pdf'),
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );

      AppLogger.i(_tag, 'PDF shared successfully');
    } catch (e, stack) {
      AppLogger.e(_tag, 'Failed to export PDF', e, stack);
      rethrow;
    }
  }

  /// Generates a CSV file containing all report metrics as Metric/Value
  /// rows and opens the device share sheet.
  static Future<void> exportAndShareCsv(ReportModel report) async {
    try {
      AppLogger.i(_tag, 'Generating CSV for report ${report.id}');

      final dateFormat = DateFormat('yyyy-MM-dd');
      final data = report.data;
      final topApps = _getTopApps(data);

      final buffer = StringBuffer()
        ..writeln('Metric,Value')
        ..writeln('Report Type,${report.type.displayName}')
        ..writeln('Start Date,${dateFormat.format(report.startDate)}')
        ..writeln('End Date,${dateFormat.format(report.endDate)}')
        ..writeln(
            'Generated At,${DateFormat('yyyy-MM-dd HH:mm').format(report.generatedAt)}')
        ..writeln('Device ID,${report.deviceId}')
        ..writeln('')
        ..writeln('Study Score,${data['studyScore'] ?? 'N/A'}')
        ..writeln('Focus Score,${data['focusScore'] ?? 'N/A'}')
        ..writeln('Distraction Score,${data['distractionScore'] ?? 'N/A'}')
        ..writeln(
            'Productivity %,${_formatPercent(data['productivityPercent'])}')
        ..writeln('')
        ..writeln(
            'Total Screen Time (min),${data['totalScreenTime'] ?? 'N/A'}')
        ..writeln('Study Hours,${data['studyHours'] ?? 'N/A'}')
        ..writeln('Entertainment Hours,${data['entertainmentHours'] ?? 'N/A'}')
        ..writeln('Education Time (min),${data['educationTime'] ?? 'N/A'}')
        ..writeln(
            'Social Media Time (min),${data['socialMediaTime'] ?? 'N/A'}')
        ..writeln('Game Time (min),${data['gameTime'] ?? 'N/A'}');

      if (topApps.isNotEmpty) {
        buffer
          ..writeln('')
          ..writeln('Top Apps');
        for (var i = 0; i < topApps.length; i++) {
          final app = topApps[i];
          final appName = app is Map ? (app['appName'] ?? app['name']) : app;
          final time = app is Map ? app['foregroundTime'] : '';
          buffer.writeln('${i + 1}. $appName,$time');
        }
      }

      if ((data['summary'] as String?)?.isNotEmpty == true) {
        buffer
          ..writeln('')
          ..writeln(
              'Summary,"${_escapeCsvValue(data['summary'] as String)}"');
      }

      final file = await _writeTempFile(
        bytes: buffer.toString().codeUnits,
        fileName: _buildFileName(report, 'csv'),
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );

      AppLogger.i(_tag, 'CSV shared successfully');
    } catch (e, stack) {
      AppLogger.e(_tag, 'Failed to export CSV', e, stack);
      rethrow;
    }
  }

  // ─── PDF Building Helpers ──────────────────────────────────────────────────

  static pw.Widget _buildPdfHeader(
    String reportType,
    String startDate,
    String endDate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _indigo, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'StudyGuardian Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _slate800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                reportType,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: _indigo,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date Range',
                style: const pw.TextStyle(fontSize: 10, color: _slate700),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '$startDate – $endDate',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _slate800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context, String generatedAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated: $generatedAt',
            style: const pw.TextStyle(fontSize: 8, color: _slate700),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _slate700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _indigo,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildMetricsTable(Map<String, dynamic> data) {
    final metrics = <List<String>>[
      [
        'Total Screen Time',
        _formatMinutes(data['totalScreenTime'] as int? ?? 0),
      ],
      ['Study Hours', '${data['studyHours'] ?? 0}h'],
      ['Entertainment Hours', '${data['entertainmentHours'] ?? 0}h'],
      [
        'Education Time',
        _formatMinutes(data['educationTime'] as int? ?? 0),
      ],
      [
        'Social Media Time',
        _formatMinutes(data['socialMediaTime'] as int? ?? 0),
      ],
      ['Game Time', _formatMinutes(data['gameTime'] as int? ?? 0)],
      [
        'Productivity',
        _formatPercent(data['productivityPercent']),
      ],
    ];

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: const pw.BoxDecoration(color: _slate800),
      headerCellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
      },
      headers: ['Metric', 'Value'],
      data: metrics,
      oddRowDecoration: const pw.BoxDecoration(color: _slate50),
    );
  }

  static pw.Widget _buildScoreBreakdown(Map<String, dynamic> data) {
    final scores = <_ScoreEntry>[
      _ScoreEntry('Study Score', data['studyScore'] as int? ?? 0, _emerald),
      _ScoreEntry('Focus Score', data['focusScore'] as int? ?? 0, _teal),
      _ScoreEntry(
          'Distraction Score', data['distractionScore'] as int? ?? 0, _red),
    ];

    return pw.Column(
      children: scores.map((score) {
        final fraction = score.value / 100.0;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text(
                  score.label,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Stack(
                  children: [
                    pw.Container(
                      height: 16,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                    ),
                    pw.FractionallySizedBox(
                      widthFactor: fraction.clamp(0.0, 1.0),
                      child: pw.Container(
                        height: 16,
                        decoration: pw.BoxDecoration(
                          color: score.color,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.SizedBox(
                width: 30,
                child: pw.Text(
                  '${score.value}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildTopAppsTable(List<dynamic> topApps) {
    final rows = <List<String>>[];
    for (var i = 0; i < topApps.length; i++) {
      final app = topApps[i];
      if (app is Map) {
        final name =
            (app['appName'] ?? app['name'] ?? 'Unknown') as String;
        final time = app['foregroundTime'] as int? ?? 0;
        rows.add(['${i + 1}', name, _formatMinutes(time)]);
      } else {
        rows.add(['${i + 1}', app.toString(), '–']);
      }
    }

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: const pw.BoxDecoration(color: _amber),
      headerCellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
      },
      headers: ['#', 'App Name', 'Usage'],
      data: rows,
      oddRowDecoration: const pw.BoxDecoration(color: _slate50),
    );
  }

  static pw.Widget _buildSummaryBlock(String summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFEEF2FF), // indigo-50
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _indigo, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '🤖 AI Insights',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _indigo,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            summary,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
          ),
        ],
      ),
    );
  }

  // ─── Utility Helpers ──────────────────────────────────────────────────────

  static List<dynamic> _getTopApps(Map<String, dynamic> data) {
    final topApps = data['topApps'];
    if (topApps is List) return topApps;
    return [];
  }

  static String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    return '${hours}h ${mins}m';
  }

  static String _formatPercent(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) return '${value.toStringAsFixed(1)}%';
    return '$value%';
  }

  static String _escapeCsvValue(String value) {
    return value.replaceAll('"', '""').replaceAll('\n', ' ');
  }

  static String _buildFileName(ReportModel report, String extension) {
    final dateStr =
        DateFormat('yyyy-MM-dd').format(report.startDate);
    return 'studyguardian_${report.type.name}_report_$dateStr.$extension';
  }

  static Future<File> _writeTempFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    AppLogger.d(_tag, 'Temp file written: ${file.path}');
    return file;
  }
}

/// Internal helper for score bar rendering in PDFs.
class _ScoreEntry {
  final String label;
  final int value;
  final PdfColor color;

  const _ScoreEntry(this.label, this.value, this.color);
}
