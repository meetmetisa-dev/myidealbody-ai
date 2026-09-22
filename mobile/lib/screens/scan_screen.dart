import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../state/app_scope.dart';
import 'result_screen.dart';

enum _ScanPhase { starting, camera, analyzing, error }
enum _LightStatus { unknown, dark, good, bright }

class ScanScreen extends StatefulWidget {
  const ScanScreen({this.openGalleryOnStart = false, super.key});

  final bool openGalleryOnStart;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  static const _settingsChannel = MethodChannel('com.myidealbody.ai/settings');

  final _picker = ImagePicker();
  CameraController? _camera;
  List<CameraDescription> _cameras = const [];
  _ScanPhase _phase = _ScanPhase.starting;
  _LightStatus _lightStatus = _LightStatus.unknown;
  String? _error;
  int _cameraIndex = 0;
  int _frame = 0;
  bool _flashEnabled = false;
  bool _openingPicker = false;
  DateTime _cameraStartedAt = DateTime.now();
  int _cameraGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverStartup());
  }

  Future<void> _recoverStartup() async {
    if (!mounted) return;
    try {
      final lost = await _picker.retrieveLostData();
      if (!mounted) return;
      final files = lost.files;
      if (files != null && files.isNotEmpty) {
        await _analyze(files.first.path, source: 'gallery');
        return;
      }
      if (lost.exception != null) {
        _showCameraError(lost.exception!.message ?? lost.exception!.code);
        return;
      }
    } on PlatformException catch (error) {
      _showCameraError(error.message ?? error.code);
      return;
    }
    if (widget.openGalleryOnStart) {
      await _pickPhoto();
    } else {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera({int index = 0}) async {
    await _disposeCamera();
    if (!mounted) return;
    final generation = ++_cameraGeneration;
    CameraController? candidate;
    setState(() {
      _phase = _ScanPhase.starting;
      _error = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('noCamera', 'No camera found');
      final cameraIndex = index.clamp(0, cameras.length - 1).toInt();
      final camera = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      candidate = camera;
      await camera.initialize();
      if (!mounted || generation != _cameraGeneration) {
        await camera.dispose();
        return;
      }
      _cameras = cameras;
      _cameraIndex = cameraIndex;
      _camera = camera;
      _cameraStartedAt = DateTime.now();
      if (!mounted) return;
      setState(() => _phase = _ScanPhase.camera);
      try {
        await camera.startImageStream(_inspectLight);
      } on CameraException {
        // The guide frame still works if this device cannot stream luminance.
      }
    } on CameraException catch (error) {
      await candidate?.dispose();
      if (generation == _cameraGeneration) {
        _showCameraError(error.description ?? error.code);
      }
    } on Exception catch (error) {
      await candidate?.dispose();
      if (generation == _cameraGeneration) _showCameraError(error.toString());
    }
  }

  void _inspectLight(CameraImage image) {
    _frame += 1;
    if (_frame % 12 != 0 || image.planes.isEmpty) return;
    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return;
    var sum = 0;
    var count = 0;
    final step = (bytes.length ~/ 450).clamp(1, 128).toInt();
    for (var index = 0; index < bytes.length; index += step) {
      sum += bytes[index];
      count++;
    }
    final average = count == 0 ? 128 : sum / count;
    final next = average < 52
        ? _LightStatus.dark
        : average > 218
            ? _LightStatus.bright
            : _LightStatus.good;
    if (next != _lightStatus && mounted) setState(() => _lightStatus = next);
  }

  void _showCameraError(String message) {
    if (!mounted) return;
    setState(() {
      _phase = _ScanPhase.error;
      _error = message;
    });
  }

  Future<void> _capture() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || camera.value.isTakingPicture) {
      return;
    }
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
      final image = await camera.takePicture();
      await _analyze(image.path, source: 'camera');
    } on CameraException catch (error) {
      _showCameraError(error.description ?? error.code);
    }
  }

  Future<void> _pickPhoto() async {
    if (_openingPicker) return;
    _openingPicker = true;
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (!mounted) return;
      if (image != null) {
        await _analyze(image.path, source: 'gallery');
      } else if (_camera == null) {
        await _initializeCamera();
      }
    } on PlatformException catch (error) {
      _showCameraError(error.message ?? error.code);
    } finally {
      _openingPicker = false;
    }
  }

  Future<void> _analyze(String imagePath, {required String source}) async {
    final controller = AppScope.of(context);
    if (!controller.cloudAnalysisConsent) return;
    setState(() {
      _phase = _ScanPhase.analyzing;
      _error = null;
    });
    try {
      final analysis = await controller.api.analyzeMeal(
        imagePath: imagePath,
        locale: controller.locale.languageCode,
        source: source,
      );
      // The bundled mock is a fixed product demo, so it must not consume a
      // user's free allowance as though a real photo analysis occurred.
      if (analysis.provider != 'mock_demo') {
        await controller.recordSuccessfulScan();
      }
      if (!mounted) {
        _deleteCapturedFile(imagePath, source);
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            initialAnalysis: analysis,
            imagePath: imagePath,
            source: source,
          ),
        ),
      );
    } on Exception catch (error) {
      _deleteCapturedFile(imagePath, source);
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _error = error.toString();
      });
    }
  }

  void _deleteCapturedFile(String imagePath, String source) {
    if (source != 'camera') return;
    try {
      final file = File(imagePath);
      if (file.existsSync()) file.deleteSync();
    } on FileSystemException {
      // The camera cache can also be cleaned by Android.
    }
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null) return;
    final next = !_flashEnabled;
    try {
      await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashEnabled = next);
    } on CameraException {
      // Some cameras do not expose a torch; leave the current state unchanged.
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    await _disposeCamera();
    await _initializeCamera(index: next);
  }

  Future<void> _disposeCamera() async {
    _cameraGeneration += 1;
    final camera = _camera;
    _camera = null;
    if (camera == null) return;
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
    } on CameraException {
      // Disposal still needs to continue.
    }
    await camera.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_disposeCamera());
      return;
    }
    if (state == AppLifecycleState.resumed &&
        mounted &&
        !_openingPicker &&
        _phase != _ScanPhase.analyzing &&
        _camera == null) {
      unawaited(_initializeCamera(index: _cameraIndex));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (_phase) {
        _ScanPhase.starting => _StartingView(onClose: () => Navigator.pop(context)),
        _ScanPhase.camera => _buildCamera(context),
        _ScanPhase.analyzing => _AnalyzingView(
            imagePath: null,
            onClose: () => Navigator.pop(context),
          ),
        _ScanPhase.error => _ErrorView(
            technicalMessage: kDebugMode ? _error : null,
            onRetry: () => _initializeCamera(index: _cameraIndex),
            onGallery: _pickPhoto,
            onOpenSettings: () => _settingsChannel.invokeMethod<void>('openAppSettings'),
            onClose: () => Navigator.pop(context),
          ),
      },
    );
  }

  Widget _buildCamera(BuildContext context) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return _StartingView(onClose: () => Navigator.pop(context));
    }
    final l10n = context.l10n;
    final guidance = DateTime.now().difference(_cameraStartedAt).inSeconds < 2
        ? l10n.fitMealInFrame
        : switch (_lightStatus) {
            _LightStatus.dark => l10n.moreLightNeeded,
            _LightStatus.bright => l10n.tooBright,
            _LightStatus.good => l10n.holdSteady,
            _LightStatus.unknown => l10n.fitMealInFrame,
          };
    final guidanceIcon = switch (_lightStatus) {
      _LightStatus.dark => Icons.wb_sunny_outlined,
      _LightStatus.bright => Icons.flare_rounded,
      _LightStatus.good => Icons.check_circle_outline_rounded,
      _LightStatus.unknown => Icons.center_focus_strong_rounded,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(camera),
        const IgnorePointer(child: CustomPaint(painter: _GuideOverlayPainter())),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.pop(context),
                      tooltip: l10n.close,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: .45),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: _toggleFlash,
                      tooltip: _flashEnabled ? l10n.flashOff : l10n.flashOn,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: .45),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(_flashEnabled ? Icons.flash_on : Icons.flash_off),
                    ),
                    if (_cameras.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _switchCamera,
                        tooltip: l10n.switchCamera,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: .45),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.cameraswitch_rounded),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Semantics(
                liveRegion: true,
                label: guidance,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .62),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(guidanceIcon, color: Colors.white),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          guidance,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.guidanceNotAnalysis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    onPressed: _pickPhoto,
                    tooltip: l10n.pickFromGallery,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(56, 56),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.capturePhoto,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _capture,
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideOverlayPainter extends CustomPainter {
  const _GuideOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .44);
    final oval = Rect.fromCenter(
      center: center,
      width: size.width * .82,
      height: size.width * .62,
    );
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(oval);
    canvas.drawPath(shade, Paint()..color = Colors.black.withValues(alpha: .28));
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StartingView extends StatelessWidget {
  const _StartingView({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.cameraStarting,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              top: 8,
              child: IconButton(
                onPressed: onClose,
                tooltip: context.l10n.close,
                color: Colors.white,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      );
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({required this.imagePath, required this.onClose});

  final String? imagePath;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imagePath != null)
          Image.file(File(imagePath!), fit: BoxFit.cover)
        else
          const ColoredBox(color: Color(0xFF092B25)),
        ColoredBox(color: Colors.black.withValues(alpha: .64)),
        SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 52,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.analyzingTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.analyzingBody,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.analysisMayTake,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  onPressed: onClose,
                  tooltip: l10n.close,
                  color: Colors.white,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.technicalMessage,
    required this.onRetry,
    required this.onGallery,
    required this.onOpenSettings,
    required this.onClose,
  });

  final String? technicalMessage;
  final VoidCallback onRetry;
  final VoidCallback onGallery;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography_outlined, color: Colors.white, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    l10n.analysisFailedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.analysisFailedBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (technicalMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      technicalMessage!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.choosePhoto),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                  TextButton(
                    onPressed: onOpenSettings,
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    child: Text(l10n.openSettings),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              onPressed: onClose,
              tooltip: l10n.close,
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
