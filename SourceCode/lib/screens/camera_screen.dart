import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/detection_painter.dart';
import '../widgets/detection_panel.dart';
import '../widgets/status_badge.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onBack;
  const CameraScreen({super.key, required this.isActive, this.onBack});

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
      if (entry.value.length >= _minVotes &&
          entry.value.length > bestCount) {
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

  bool _sessionStarted = false;

  int _consecutiveFailures = 0;
  static const int _maxFailuresBeforeOffline = 4;

  final _LabelSmoother _smoother = _LabelSmoother();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(CameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive) _stopSession();
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
    if (!widget.isActive || !_sessionStarted) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _captureTimer?.cancel();
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _pingThenInit();
    }
  }

  void _stopSession() {
    _captureTimer?.cancel();
    _controller?.dispose();
    _controller = null;
    _smoother.clear();
    if (mounted) {
      setState(() {
        _sessionStarted = false;
        _detections = [];
        _tracking   = [];
        _lastLabel  = '';
        _serverStatus = ServerStatus.connecting;
      });
    }
  }

  Future<void> _startSession() async {
    setState(() => _sessionStarted = true);
    await _pingThenInit();
  }

  Future<void> _pingThenInit() async {
    setState(() => _serverStatus = ServerStatus.connecting);
    try {
      final res = await http.get(
          Uri.parse('$kServerBase/health'),
          headers: {'X-API-Key': kApiKey},
        ).timeout(kStartupPingTimeout);
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
    _captureTimer =
        Timer.periodic(kCaptureInterval, (_) => _captureAndSend());
  }

  Future<void> _captureAndSend() async {
    if (_isProcessing ||
        _controller == null ||
        !_controller!.value.isInitialized) return;

    _isProcessing = true;
    try {
      final image   = await _controller!.takePicture();
      final request =
          http.MultipartRequest('POST', Uri.parse('$kServerBase/predict'));
      request.files
          .add(await http.MultipartFile.fromPath('file', image.path));
      request.headers['X-API-Key'] = kApiKey;

      final response = await request.send().timeout(kRequestTimeout);
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);

        if (mounted) {
          final newDetections = List<dynamic>.from(data['detections'] ?? []);
          final newTracking   = List<dynamic>.from(data['tracking'] ?? []);

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
    final l10n = AppLocalizations.of(context)!;

    if (!_sessionStarted) {
      return _IdleStartScreen(
        onStart: _startSession,
        onBack: () {
          _stopSession();
          widget.onBack?.call();
        },
        l10n: l10n,
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFF0A0F0F))),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                      color: kGreen500, strokeWidth: 2),
                  const SizedBox(height: 20),
                  Text(
                    l10n.cameraInitialising,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: _HudButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () { _stopSession(); widget.onBack?.call(); },
              ),
            ),
          ],
        ),
      );
    }

    final secondary = _detections.length > 1
        ? _detections.where((d) => d != _topDetection).take(2).toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedCameraPane(
              controller: _controller!,
              detections: _detections,
              tracking:   _tracking,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _HudButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () { _stopSession(); widget.onBack?.call(); },
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: StatusBadge(status: _serverStatus),
                  ),
                ),
                const SizedBox(width: 8),
                _HudButton(
                  icon: Icons.stop_rounded,
                  onTap: _stopSession,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DetectionPanel(
                  top:       _topDetection,
                  secondary: secondary,
                  labelKey:  _lastLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleStartScreen extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onBack;
  final AppLocalizations l10n;

  const _IdleStartScreen({
    required this.onStart,
    required this.onBack,
    required this.l10n,
  });

  @override
  State<_IdleStartScreen> createState() => _IdleStartScreenState();
}

class _IdleStartScreenState extends State<_IdleStartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: kBgGradient),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _rotCtrl,
              builder: (_, __) => CustomPaint(
                size: const Size(320, 320),
                painter:
                    _IdleRingPainter(_rotCtrl.value, _pulseCtrl.value),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final glow = 0.3 + _pulseCtrl.value * 0.4;
                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGreen500.withOpacity(0.12),
                        border: Border.all(
                          color: kGreen400
                              .withOpacity(0.4 + _pulseCtrl.value * 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kGreen500.withOpacity(glow * 0.5),
                            blurRadius: 32 + _pulseCtrl.value * 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.videocam_rounded,
                          color: kGreen400, size: 38),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.cameraIdleTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.cameraIdleSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                _StartButton(onTap: widget.onStart, label: l10n.cameraStartSession),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _HudButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  const _StartButton({required this.onTap, required this.label});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _scale = 0.94),
      onTapUp:    (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 180,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                  color: kGreen500.withOpacity(0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleRingPainter extends CustomPainter {
  final double rot;
  final double pulse;
  _IdleRingPainter(this.rot, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    const radii        = [60.0, 100.0, 140.0];
    const baseOpacity  = [0.18,  0.10,   0.05];
    const dashCounts   = [8,     12,     16];

    for (int r = 0; r < radii.length; r++) {
      final opacity = baseOpacity[r] + pulse * 0.06;
      final paint = Paint()
        ..color = kGreen400.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final dashes = dashCounts[r];
      final step   = 2 * math.pi / dashes;
      final offset = rot * math.pi * 2 * (r.isEven ? 1 : -1);

      for (int i = 0; i < dashes; i++) {
        if (i.isEven) continue;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: radii[r]),
          i * step + offset,
          step * 0.7,
          false,
          paint,
        );
      }
    }

    final dotAngle = rot * math.pi * 2;
    canvas.drawCircle(
      Offset(cx + math.cos(dotAngle) * 100, cy + math.sin(dotAngle) * 100),
      3.5 + pulse * 1.5,
      Paint()..color = kGreen400.withOpacity(0.6 + pulse * 0.3),
    );
  }

  @override
  bool shouldRepaint(_IdleRingPainter old) =>
      old.rot != rot || old.pulse != pulse;
}

class _HudButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _HudButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  State<_HudButton> createState() => _HudButtonState();
}

class _HudButtonState extends State<_HudButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _scale = 0.88),
      onTapUp:    (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: Icon(widget.icon,
                  color: Colors.white, size: widget.size * 0.42),
            ),
          ),
        ),
      ),
    );
  }
}