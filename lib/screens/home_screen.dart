import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ContactGroupViewScreen extends StatefulWidget {
  const ContactGroupViewScreen({super.key});

  @override
  State<ContactGroupViewScreen> createState() => _ContactGroupViewScreenState();
}

class _ContactGroupViewScreenState extends State<ContactGroupViewScreen> {
  DataTable? _dataTable;
  Future<void> pickAndReadExcelFile() async {
    // Step 1: Pick file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      // Step 2: Read bytes of the selected file
      final bytes = File(result.files.single.path!).readAsBytesSync();

      // Step 3: Create an Excel object from the bytes
      final excel = Excel.decodeBytes(bytes);

      // Get the first sheet
      final sheet = excel.sheets.values.first;

      // Create a DataTable from the sheet data
      final dataTable = DataTable(
        columns:
            sheet.rows.first
                .map((cell) => DataColumn(label: Text(cell!.value.toString())))
                .toList(),
        rows:
            sheet.rows
                .sublist(1)
                .map(
                  (row) => DataRow(
                    cells:
                        row
                            .map(
                              (cell) => DataCell(Text(cell!.value.toString())),
                            )
                            .toList(),
                  ),
                )
                .toList(),
      );

      // Update the UI to display the DataTable
      setState(() {
        _dataTable = dataTable;
      });
    } else {
      if (kDebugMode) {
        print('File picking cancelled.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            pickAndReadExcelFile();
          });
        },
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
        title: Text(
          "Contact Group View",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            (_dataTable == null)
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      Text("No data", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
                : ListView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // Allow horizontal scrolling
                      child: _dataTable,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
        // : InteractiveViewer(
        //   constrained: false,
        //   boundaryMargin: const EdgeInsets.all(20.0),
        //   minScale: 0.1,
        //   maxScale: 5.0,
        //   panEnabled: true,
        //   scaleEnabled: true,
        //   child: _dataTable ?? const SizedBox.shrink(),
        // ),
      ),
    );
  }
}
