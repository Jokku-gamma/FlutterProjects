import 'dart:async';          // For Timer
import 'dart:convert';        // For jsonDecode
import 'dart:io';             // For File
import 'dart:typed_data';     // For Uint8List
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';          // Camera package
import 'package:http/http.dart' as http;      // HTTP requests
import 'package:permission_handler/permission_handler.dart'; // Camera permission
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Image compression

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  Timer? _timer;
  Map<String, dynamic> _results = {};
  final String _apiUrl = "https://objectcounter.onrender.com/detect/";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (await Permission.camera.request().isGranted) {
      _cameras = await availableCameras();
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } else {
      print('Camera permission denied');
    }
  }

  void _toggleDetection() {
    setState(() {
      _isDetecting = !_isDetecting;
    });

    if (_isDetecting) {
      _timer = Timer.periodic(Duration(seconds: 2), (timer) => _captureAndDetect());
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _captureAndDetect() async {
    if (!_controller!.value.isInitialized) return;

    try {
      XFile imageFile = await _controller!.takePicture();
      File file = File(imageFile.path);
      
      // Compress image
      // Check for null before assignment
Uint8List? compressedImageNullable = await FlutterImageCompress.compressWithFile(
  file.path,
  quality: 50,
);

if (compressedImageNullable == null) {
  print('Image compression failed');
  return;
}

Uint8List compressedImage = compressedImageNullable; // Now safe to assign
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          compressedImage,
          filename: 'image.jpg',
        ));

      var response = await request.send();
      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        setState(() {
          _results = jsonDecode(body);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _buildResultsOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDetection,
        child: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildResultsOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detected Objects:',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            ..._results['counts']?.entries.map<Widget>((entry) {
              return Text('${entry.key}: ${entry.value}',
                  style: TextStyle(color: Colors.white));
            })?.toList() ?? [Text('No objects detected', style: TextStyle(color: Colors.white))],
          ],
        ),
      ),
    );
  }
}