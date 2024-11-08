import 'package:hive/hive.dart';
import 'report_model.dart';

class ReportRepository {
  final String _boxName = 'reports';

  Future<Box<Report>> _getBox() async {
    return await Hive.openBox<Report>(_boxName);
  }

  // Create
  Future<void> addReport(Report report) async {
    final box = await _getBox();
    await box.put(report.id, report);
  }

  // Read
  Future<List<Report>> getReports() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // Update
  Future<void> updateReport(Report report) async {
    final box = await _getBox();
    await box.put(report.id, report);
  }

  // Delete
  Future<void> deleteReport(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
