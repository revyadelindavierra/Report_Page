import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lapor_app/input_report_page.dart';
import 'report_repository.dart';
import 'report_model.dart';

class ListReportPage extends StatefulWidget {
  const ListReportPage({Key? key}) : super(key: key);

  @override
  _ListReportPageState createState() => _ListReportPageState();
}

class _ListReportPageState extends State<ListReportPage> {
  final ReportRepository _repository = ReportRepository();
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await _repository.getReports();
    setState(() {
      _reports = reports;
    });
  }

  Future<void> _deleteReport(Report report) async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi hapus'),
          content: Text('Yakin akan menghapus laporan?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _repository.deleteReport(report.id);
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];

                Widget leadingWidget;

                if (report.photoPath != null && report.photoPath!.isNotEmpty) {
                  if (kIsWeb) {
                    String base64String = report.photoPath ?? '';

                    leadingWidget = base64String.isNotEmpty
                        ? Image.memory(
                            base64Decode(base64String),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Text(
                            'Belum ada data',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                  } else {
                    leadingWidget = Image.file(
                      File(report.photoPath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    );
                  }
                } else {
                  leadingWidget = Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  );
                }

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: leadingWidget,
                    title: Text(
                      report.description,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Tags: ${report.tags.join(', ')}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InputReportPage(report: report),
                              ),
                            ).then((_) {
                              _loadReports();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteReport(report);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
