import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_converter_app/providers/conversion_provider.dart';
import 'package:media_converter_app/widgets/format_selector.dart';

class UrlConverter extends StatefulWidget {
  const UrlConverter({super.key});

  @override
  UrlConverterState createState() => UrlConverterState();
}

class UrlConverterState extends State<UrlConverter> {
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConversionProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: "Media URL",
              hintText: "https://example.com/media.mp3",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 20),
          const FormatSelector(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.convert),
            label: const Text("Convert Media"),
            onPressed: () {
              provider.convertFromUrl(_urlController.text);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}