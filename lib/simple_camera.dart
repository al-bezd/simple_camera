import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SimpleCamera extends StatefulWidget {
  const SimpleCamera({
    super.key,
    this.onTakePhoto,
    this.resolution,
    this.enableAudio = false,
    this.fps = 30,
    this.format = ImageFormatGroup.jpeg,
  });
  final void Function(XFile file)? onTakePhoto;
  final ResolutionPreset? resolution;
  final bool enableAudio;
  final int fps;
  final ImageFormatGroup format;

  static List<CameraDescription> cameras = [];
  static GlobalKey<NavigatorState>? _navigatorKey;
  static void initialize({required GlobalKey<NavigatorState> navigatorKey}) {
    _navigatorKey = navigatorKey;
  }

  static show(Function(XFile file)? onTakePhoto) {
    final context = _navigatorKey?.currentState?.context;
    if (context == null) {
      throw Exception(
        'NavigatorKey not initialized. Call SimpleCamera.initialize() first',
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleCamera(onTakePhoto: onTakePhoto),
      ),
    );
  }

  @override
  State<SimpleCamera> createState() => _SimpleCameraState();
}

class _SimpleCameraState extends State<SimpleCamera> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (SimpleCamera.cameras.isEmpty) {
      SimpleCamera.cameras = await availableCameras();
    }

    _controller = CameraController(
      enableAudio: widget.enableAudio,
      fps: widget.fps,
      imageFormatGroup: widget.format,
      SimpleCamera
          .cameras[0], // Use the first available camera (usually back camera)
      widget.resolution ?? ResolutionPreset.medium,
    );
    await _controller!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile file = await _controller!.takePicture();

      widget.onTakePhoto?.call(file);
    } on CameraException catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CameraPreview(_controller!)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _takePicture();
          if (context.mounted) {
            // Проверяем mounted у контекста
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
