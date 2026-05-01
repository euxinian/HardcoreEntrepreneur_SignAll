import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/theme.dart';
import '../widgets/detection_painter.dart';
import '../widgets/detection_panel.dart';
import '../widgets/status_badge.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  final bool isActive;
  const CameraScreen({super.key, required this.isActive});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _LabelSmoother {
  static const int _windowSize = 5;
  static const int _minVotes   = 3;

  final Queue<Map<String, dynamic>?> _window = Queue();

  void push(Map<String, dynamic>? detection) {
    _window.addLast(detection);
    if (_window.length > _windowSize) _window.removeFirst();
  }

  Map<String, dynamic>? get confirmed {
    if (_window.isEmpty) return null;
    final Map<String, List<double>> votes = {};
    for (final d in _window) {
      if (d == null) continue;
      final label = d['label'] as String;
      if (label.isEmpty) continue;
      votes.putIfAbsent(label, () => []);
      votes[label]!.add((d['confidence'] as num).toDouble());
    }
    String? bestLabel;
    int bestCount = 0;
    for (final entry in votes.entries) {
      if (entry.value.length >= _minVotes && entry.value.length > bestCount) {
        bestLabel = entry.key;
        bestCount = entry.value.length;
      }
    }
    if (bestLabel == null) return null;
    return _window.lastWhere(
      (d) => d != null && d['label'] == bestLabel,
      orElse: () => null,
    );
  }

  void clear() => _window.clear();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Timer? _captureTimer;

  List<dynamic> _detections = [];
  List<dynamic> _tracking   = [];

  bool _isProcessing = false;
  ServerStatus _serverStatus = ServerStatus.connecting;
  String _lastLabel = '';

  int _consecutiveFailures = 0;
  static const int _maxFailuresBeforeOffline = 4;

  final _LabelSmoother _smoother = _LabelSmoother();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) _pingThenInit();
  }

  @override
  void didUpdateWidget(CameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pingThenInit();
    } else if (!widget.isActive && oldWidget.isActive) {
      _captureTimer?.cancel();
      _controller?.dispose();
      _controller = null;
      _smoother.clear();
      if (mounted) setState(() { _detections = []; _tracking = []; _lastLabel = ''; });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _captureTimer?.cancel();
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _pingThenInit();
    }
  }

  Future<void> _pingThenInit() async {
    debugPrint('Connecting to: $kServerBase');
    setState(() => _serverStatus = ServerStatus.connecting);
    try {
      final res = await http
          .get(Uri.parse('$kServerBase/health'))
          .timeout(kStartupPingTimeout);
      setState(() => _serverStatus = res.statusCode == 200
          ? ServerStatus.connected
          : ServerStatus.reloading);
    } catch (_) {
      setState(() => _serverStatus = ServerStatus.disconnected);
    }
    await _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    _captureTimer?.cancel();
    await _controller?.dispose();

    final selected = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Camera error: $e');
      return;
    }

    if (!mounted) return;
    _consecutiveFailures = 0;
    _smoother.clear();
    setState(() {});
    _captureTimer = Timer.periodic(kCaptureInterval, (_) => _captureAndSend());
  }

  Future<void> _captureAndSend() async {
    if (_isProcessing ||
        _controller == null ||
        !_controller!.value.isInitialized) return;

    _isProcessing = true;
    try {
      final image   = await _controller!.takePicture();
      final request = http.MultipartRequest('POST', Uri.parse('$kServerBase/predict'));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.headers['X-API-Key'] = kApiKey;

      final response = await request.send().timeout(kRequestTimeout);
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);

        if (mounted) {
          final newDetections = List<dynamic>.from(data['detections'] ?? []);
          final newTracking   = List<dynamic>.from(data['tracking']   ?? []);

          final top = newDetections.isNotEmpty
              ? newDetections.reduce((a, b) =>
                  (a['confidence'] as num) >= (b['confidence'] as num) ? a : b)
              : null;
          _smoother.push(top != null ? Map<String, dynamic>.from(top) : null);
          final confirmedLabel = _smoother.confirmed;

          _consecutiveFailures = 0;
          setState(() {
            _detections   = newDetections;
            _tracking     = newTracking;
            _serverStatus = ServerStatus.connected;
            _lastLabel    = confirmedLabel?['label'] as String? ?? '';
          });
        }
      } else {
        if (mounted) setState(() => _serverStatus = ServerStatus.reloading);
      }
    } catch (_) {
      _consecutiveFailures++;
      if (mounted && _consecutiveFailures >= _maxFailuresBeforeOffline) {
        _smoother.clear();
        setState(() {
          _detections   = [];
          _tracking     = [];
          _lastLabel    = '';
          _serverStatus = ServerStatus.disconnected;
        });
      }
    } finally {
      _isProcessing = false;
    }
  }

  Map<String, dynamic>? get _topDetection {
    if (_detections.isEmpty) return null;
    return _detections.reduce((a, b) =>
        (a['confidence'] as num) >= (b['confidence'] as num) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 1.5),
        ),
      );
    }

    final secondary = _detections.length > 1
        ? _detections.where((d) => d != _topDetection).take(2).toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(status: _serverStatus),
            Expanded(
              child: AnimatedCameraPane(
                controller: _controller!,
                detections: _detections,
                tracking:   _tracking,
              ),
            ),
            DetectionPanel(
              top:      _topDetection,
              secondary: secondary,
              labelKey:  _lastLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ServerStatus status;
  const _TopBar({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF), width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Text('SignAll Live Mode',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5)),
          const Spacer(),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}