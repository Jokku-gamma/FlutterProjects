import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_converter_app/providers/conversion_provider.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConversionProvider>(context);
    
    return DropdownButtonFormField<String>(
      value: provider.selectedFormat,
      hint: const Text("Select output format"),
      items: provider.allFormats
          .map((format) => DropdownMenuItem(
                value: format,
                child: Text(format.toUpperCase()),
              ))
          .toList(),
      onChanged: (value) => provider.setSelectedFormat(value!),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.format_list_bulleted),
      ),
    );
  }
}