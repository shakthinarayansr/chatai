import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

class JsonDisplayPage extends StatelessWidget {
  final Map<String, dynamic> jsonData;

  const JsonDisplayPage({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Viewer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: JsonViewer(jsonData),
      ),
    );
  }
}
