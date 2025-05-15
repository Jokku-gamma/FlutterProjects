import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chameleon App',
      theme: ThemeData.dark(),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Color _dominantColor = Colors.black;
  Timer? _timer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    await _controller.initialize();
    _startColorCapture();
  }

  void _startColorCapture() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isProcessing) {
        _isProcessing = true;
        await _captureAndProcessFrame();
        _isProcessing = false;
      }
    });
  }

  Future<void> _captureAndProcessFrame() async {
    try {
      final image = await _controller.takePicture();
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      final color = await _getDominantColor(imageBytes);
      setState(() => _dominantColor = color);
    } catch (e) {
      print('Error capturing frame: $e');
    }
  }

  Future<Color> _getDominantColor(Uint8List imageBytes) async {
    final uri = Uri.parse('https://chameleonapp.onrender.com/detect/');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(body);
        return Color.fromRGBO(
          jsonResponse['r'],
          jsonResponse['g'],
          jsonResponse['b'],
          1.0,
        );
      }
      return Colors.black;
    } catch (e) {
      print('Error getting dominant color: $e');
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            CameraPreview(_controller),
          Container(
            color: _dominantColor.withOpacity(0.7),
          ),
          if (!_controller.value.isInitialized)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}