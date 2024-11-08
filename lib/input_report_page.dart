import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:lapor_app/report_model.dart';
import 'package:lapor_app/report_repository.dart';

class InputReportPage extends StatefulWidget {
  final Report? report;
  const InputReportPage({super.key, this.report});

  @override
  _InputReportPageState createState() => _InputReportPageState();
}

class _InputReportPageState extends State<InputReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  String? selectedImageBase64;
  List<String> selectedTags = [];
  final List<String> availableTags = [
    'Kecelakaan',
    'Bencana Alam',
    'Kebakaran',
    'Kejahatan',
    'Gangguan Listrik',
    'Kesehatan',
    'Lainnya'
  ];

  ReportRepository reportRepository = ReportRepository();

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      descriptionController.text = widget.report!.description;
      selectedTags = List<String>.from(widget.report!.tags);
      if (kIsWeb) {
        selectedImageBase64 = widget.report!.photoPath;
      } else {
        selectedImage = File(widget.report!.photoPath);
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        if (kIsWeb) {
          selectedImageBase64 = base64Encode(result.files.single.bytes!);
        } else {
          selectedImage = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> saveReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      final description = descriptionController.text;
      if (kIsWeb) {
        if (selectedImageBase64 != null) {
          final report = Report(
            id: widget.report?.id ?? UniqueKey().toString(),
            description: description,
            tags: selectedTags,
            photoPath: selectedImageBase64!,
          );
          if (widget.report == null) {
            await reportRepository.addReport(report);
          } else {
            await reportRepository.updateReport(report);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mohon pilih foto laporan')),
          );
          return;
        }
      } else {
        if (selectedImage != null) {
          final report = Report(
            id: widget.report?.id ?? UniqueKey().toString(),
            description: description,
            tags: selectedTags,
            photoPath: selectedImage!.path,
          );
          if (widget.report == null) {
            await reportRepository.addReport(report);
          } else {
            await reportRepository.updateReport(report);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mohon pilih foto laporan')),
          );
        }
      }
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'Tambah Laporan' : 'Edit Laporan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deskripsi
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // Pilih Foto
              Text('Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: (kIsWeb && selectedImageBase64 != null)
                        ? Image.memory(base64Decode(selectedImageBase64!),
                            height: 150, fit: BoxFit.cover)
                        : (selectedImage != null
                            ? Image.file(selectedImage!,
                                height: 150, fit: BoxFit.cover)
                            : Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              // Tag
              Text('Tag',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 12.0,
                children: availableTags.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: selectedTags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 174, 191, 221)
                        .withOpacity(0.3),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
              SizedBox(height: 30.0),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveReport,
                  child: Text(widget.report == null ? 'Simpan' : 'Perbarui'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color.fromARGB(255, 25, 39, 64),
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
