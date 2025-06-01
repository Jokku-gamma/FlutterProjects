import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_converter_app/providers/conversion_provider.dart';
import 'package:media_converter_app/widgets/format_selector.dart';
import 'package:media_converter_app/widgets/url_converter.dart';
import 'package:media_converter_app/widgets/file_converter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Universal Media Converter'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.link), text: "From URL"),
              Tab(icon: Icon(Icons.upload_file), text: "From Device"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showSupportedFormats(context),
            ),
          ],
        ),
        body: Consumer<ConversionProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            
            return const TabBarView(
              children: [
                UrlConverter(),
                FileConverter(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSupportedFormats(BuildContext context) {
    final provider = Provider.of<ConversionProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supported Formats"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Audio Formats:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: provider.audioFormats
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text("Video Formats:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: provider.videoFormats
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}