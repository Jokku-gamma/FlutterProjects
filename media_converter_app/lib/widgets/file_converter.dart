import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_converter_app/providers/conversion_provider.dart';
import 'package:media_converter_app/widgets/format_selector.dart';

class FileConverter extends StatelessWidget {
  const FileConverter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConversionProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: provider.pickFile,
            child: const Text("Select Media File"),
          ),
          const SizedBox(height: 16),
          Text(
            provider.fileName ?? "No file selected",
            style: TextStyle(
              color: provider.fileName != null ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const FormatSelector(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.convert),
            label: const Text("Convert Media"),
            onPressed: provider.convertFromFile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}