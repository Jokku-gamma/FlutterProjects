import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart'; // Not strictly needed for this version

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    print('No cameras found.');
    // Handle case where no cameras are available
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('No cameras found.')))));
    return;
  }
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
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false, // Audio is not needed for this app
    );

    try {
      await _controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
      _startColorCapture();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
      // Handle camera initialization errors
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  void _startColorCapture() {
    // Adjusted interval for potentially smoother updates, but be mindful of API usage.
    // If you need more frequent updates, consider processing frames directly on the device.
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async { // Capture every 0.5 seconds
      if (!_isProcessing && _controller.value.isInitialized) {
        _isProcessing = true;
        await _captureAndProcessFrame();
        _isProcessing = false;
      }
    });
  }

  Future<void> _captureAndProcessFrame() async {
    try {
      final XFile image = await _controller.takePicture();
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      final color = await _getDominantColor(imageBytes);
      if (mounted) {
        setState(() => _dominantColor = color);
      }
    } catch (e) {
      print('Error capturing or processing frame: $e');
    }
  }

  Future<Color> _getDominantColor(Uint8List imageBytes) async {
    final uri = Uri.parse('https://chameleonapp.onrender.com/detect/');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg')); // Added filename

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(body);
        // Ensure values are integers and within 0-255 range
        final r = (jsonResponse['r'] as int).clamp(0, 255);
        final g = (jsonResponse['g'] as int).clamp(0, 255);
        final b = (jsonResponse['b'] as int).clamp(0, 255);
        return Color.fromRGBO(r, g, b, 1.0);
      } else {
        print('API Error: ${response.statusCode} - ${response.reasonPhrase}');
        final errorBody = await response.stream.bytesToString();
        print('Error Body: $errorBody');
      }
      return Colors.black; // Return black on API error
    } catch (e) {
      print('Error getting dominant color from API: $e');
      return Colors.black; // Return black on network or parsing error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
          // Dominant color overlay
          Positioned.fill(
            child: Container(
              color: _dominantColor.withOpacity(0.7), // Adjust opacity as needed
            ),
          ),
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