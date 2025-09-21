import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SimpleCamera extends StatefulWidget {
  const SimpleCamera({
    super.key,
    this.onTakePhoto,
    this.resolution,
    this.enableAudio = false,
    this.fps,
    this.format = ImageFormatGroup.jpeg,
    this.takePhotoBtnWidget,
  });
  final void Function(XFile file)? onTakePhoto;
  final ResolutionPreset? resolution;
  final bool enableAudio;
  final int? fps;
  final ImageFormatGroup format;
  final Widget? takePhotoBtnWidget;

  //
  static List<CameraDescription> cameras = [];
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void initialize({required GlobalKey<NavigatorState> navigatorKey}) {
    _navigatorKey = navigatorKey;
  }

  static show(
    Function(XFile file)? onTakePhoto, {
    Widget? takePhotoBtnWidget,
    ImageFormatGroup format = ImageFormatGroup.jpeg,
    int? fps,
    ResolutionPreset? resolution,
  }) {
    final context = _navigatorKey?.currentState?.context;
    if (context == null) {
      throw Exception(
        'NavigatorKey not initialized. Call SimpleCamera.initialize() first',
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleCamera(
          onTakePhoto: onTakePhoto,
          takePhotoBtnWidget: takePhotoBtnWidget,
          format: format,
          fps: fps,
          resolution: resolution,
        ),
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

    onPressed() async {
      await _takePicture();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CameraPreview(_controller!)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlashButton(controller: _controller),
            widget.takePhotoBtnWidget != null
                ? GestureDetector(
                    onTap: onPressed,
                    child: widget.takePhotoBtnWidget,
                  )
                : GestureDetector(
                    onTap: onPressed,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
            GestureDetector(
              child: const Icon(Icons.close, color: Colors.white),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FlashButton extends StatefulWidget {
  final CameraController? controller;

  const FlashButton({super.key, required this.controller});

  @override
  State<FlashButton> createState() => _FlashButtonState();
}

class _FlashButtonState extends State<FlashButton> {
  @override
  Widget build(BuildContext context) {
    switch (widget.controller?.value.flashMode) {
      case FlashMode.auto:
        return GestureDetector(
          child: const Icon(Icons.flash_auto, color: Colors.white),
          onTap: () async {
            await widget.controller?.setFlashMode(FlashMode.torch);
            setState(() {});
          },
        );
      case FlashMode.torch:
        return GestureDetector(
          child: const Icon(Icons.flash_on, color: Colors.white),
          onTap: () async {
            await widget.controller?.setFlashMode(FlashMode.off);
            setState(() {});
          },
        );
      case FlashMode.off:
        return GestureDetector(
          child: const Icon(Icons.flash_off, color: Colors.white),
          onTap: () async {
            await widget.controller?.setFlashMode(FlashMode.auto);
            setState(() {});
          },
        );
      default:
        return const SizedBox();
    }
  }
}
