import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ConversionProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _fileName;
  String? _selectedFormat;
  List<String> _audioFormats = [];
  List<String> _videoFormats = [];
  final String _baseUrl = "https://your-huggingface-space-url.hf.space"; // Replace with your URL

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get fileName => _fileName;
  String? get selectedFormat => _selectedFormat;
  List<String> get audioFormats => _audioFormats;
  List<String> get videoFormats => _videoFormats;
  List<String> get allFormats => [..._audioFormats, ..._videoFormats];

  ConversionProvider() {
    fetchSupportedFormats();
  }

  Future<void> fetchSupportedFormats() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/health"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _audioFormats = List<String>.from(data['supported_audio_formats']);
        _videoFormats = List<String>.from(data['supported_video_formats']);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to load formats: $e";
      notifyListeners();
    }
  }

  void setSelectedFormat(String format) {
    _selectedFormat = format;
    notifyListeners();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _fileName = result.files.single.name;
      notifyListeners();
    }
  }

  Future<void> convertFromUrl(String url) async {
    if (url.isEmpty || _selectedFormat == null) {
      _error = "Please enter URL and select format";
      notifyListeners();
      return;
    }

    await _performConversion(
      request: () async => http.post(
        Uri.parse("$_baseUrl/convert/url"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'url': url,
          'output_format': _selectedFormat,
        }),
      ),
    );
  }

  Future<void> convertFromFile() async {
    if (_fileName == null || _selectedFormat == null) {
      _error = "Please select a file and format";
      notifyListeners();
      return;
    }

    final file = File(FilePicker.platform.files.single.path!);
    await _performConversion(
      request: () async {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("$_baseUrl/convert/upload"),
        );
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: _fileName,
        ));
        request.fields['output_format'] = _selectedFormat!;
        return http.Response.fromStream(await request.send());
      },
    );
  }

  Future<void> _performConversion({required Future<http.Response> Function() request}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await request();
      
      if (response.statusCode == 200) {
        // Save file locally
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/converted.$_selectedFormat';
        await File(filePath).writeAsBytes(response.bodyBytes);
        
        // Open the file
        await OpenFile.open(filePath);
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Conversion failed';
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}