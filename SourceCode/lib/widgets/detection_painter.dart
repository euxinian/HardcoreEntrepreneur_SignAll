import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants/theme.dart';

class _AnimatedBox {
  double l, t, r, b;
  double tl, tt, tr, tb;

  double opacity;
  double targetOpacity;
  double scale;

  final bool      isTracking;
  final List<int> color;
  final String    label;

  _AnimatedBox({
    required this.l, required this.t,
    required this.r, required this.b,
    required this.color,
    required this.label,
    required this.isTracking,
  })  : tl = l, tt = t, tr = r, tb = b,
        opacity       = 0.0,
        targetOpacity = 1.0,
        scale         = 0.88;

  bool get alive => opacity > 0.01;

  Rect get scaledRect {
    final cx = (l + r) / 2;
    final cy = (t + b) / 2;
    final hw = (r - l) / 2 * scale;
    final hh = (b - t) / 2 * scale;
    return Rect.fromLTRB(cx - hw, cy - hh, cx + hw, cy + hh);
  }
}


class DetectionPainter extends CustomPainter {
  final List<_AnimatedBox> boxes;
  const DetectionPainter(this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boxes) {
      if (!box.isTracking || !box.alive) continue;
      _drawTracking(canvas, box);
    }
    for (final box in boxes) {
      if (box.isTracking || !box.alive) continue;
      _drawConfirmed(canvas, box);
    }
  }

  void _drawTracking(Canvas canvas, _AnimatedBox box) {
    final rect  = box.scaledRect;
    final paint = Paint()
      ..color      = Colors.white.withOpacity(0.28 * box.opacity)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    _drawDashedRect(canvas, rect.left, rect.top, rect.right, rect.bottom, paint);
  }

  void _drawConfirmed(Canvas canvas, _AnimatedBox box) {
    final rect  = box.scaledRect;
    final color = Color.fromRGBO(box.color[0], box.color[1], box.color[2], 1.0);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    canvas.drawRRect(rRect,
        Paint()..color = color.withOpacity(0.07 * box.opacity));
    canvas.drawRRect(rRect,
        Paint()
          ..color      = color.withOpacity(0.85 * box.opacity)
          ..style      = PaintingStyle.stroke
          ..strokeWidth = 1.8);
    _drawCorners(canvas, rect.left, rect.top, rect.right, rect.bottom,
        color, box.opacity);
  }

  void _drawDashedRect(Canvas canvas,
      double l, double t, double r, double b, Paint paint) {
    const double dash = 8.0;
    const double gap  = 5.0;

    void dashLine(Offset from, Offset to) {
      final len = (to - from).distance;
      if (len == 0) return;
      final ux = (to.dx - from.dx) / len;
      final uy = (to.dy - from.dy) / len;
      double drawn  = 0;
      bool   drawing = true;
      while (drawn < len) {
        final seg = drawing ? dash : gap;
        final end = (drawn + seg).clamp(0.0, len);
        if (drawing) {
          canvas.drawLine(
            Offset(from.dx + ux * drawn, from.dy + uy * drawn),
            Offset(from.dx + ux * end,   from.dy + uy * end),
            paint,
          );
        }
        drawn   += seg;
        drawing  = !drawing;
      }
    }

    dashLine(Offset(l, t), Offset(r, t));
    dashLine(Offset(r, t), Offset(r, b));
    dashLine(Offset(r, b), Offset(l, b));
    dashLine(Offset(l, b), Offset(l, t));
  }

  void _drawCorners(Canvas canvas,
      double l, double t, double r, double b, Color color, double opacity) {
    const double len = 14.0;
    final paint = Paint()
      ..color      = Colors.white.withOpacity(0.85 * opacity)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap  = StrokeCap.round;

    final segs = [
      [Offset(l, t + len), Offset(l, t),     Offset(l + len, t)],
      [Offset(r - len, t), Offset(r, t),     Offset(r, t + len)],
      [Offset(l, b - len), Offset(l, b),     Offset(l + len, b)],
      [Offset(r - len, b), Offset(r, b),     Offset(r, b - len)],
    ];
    for (final s in segs) {
      canvas.drawPath(
        Path()
          ..moveTo(s[0].dx, s[0].dy)
          ..lineTo(s[1].dx, s[1].dy)
          ..lineTo(s[2].dx, s[2].dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DetectionPainter _) => true;
}


class AnimatedCameraPane extends StatefulWidget {
  final CameraController controller;
  final List<dynamic> detections; 
  final List<dynamic> tracking;   

  const AnimatedCameraPane({
    super.key,
    required this.controller,
    required this.detections,
    required this.tracking,
  });

  @override
  State<AnimatedCameraPane> createState() => _AnimatedCameraPaneState();
}

class _AnimatedCameraPaneState extends State<AnimatedCameraPane>
    with SingleTickerProviderStateMixin {

  static const double _kOffsetX = 0.0; 
  static const double _kOffsetY = 1.5; 

  static const double _kPosLerp             = 0.22;
  static const double _kFadeInLerp          = 0.25;
  static const double _kFadeOutLerp         = 0.14;
  static const double _kScaleLerp           = 0.22;
  static const double _kTrackingMatchRadius = 200.0;
  static const double _kMinBoxAreaFraction  = 0.04;

  late final Ticker _ticker;
  final List<_AnimatedBox> _boxes = [];

  Size _widgetSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(AnimatedCameraPane old) {
    super.didUpdateWidget(old);
    if (old.detections != widget.detections ||
        old.tracking    != widget.tracking) {
      _reconcile();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  (double, double, double, double)? _toCanvas(
    List<dynamic> box,
    Size canvasSize,
  ) {
    final ar        = widget.controller.value.aspectRatio / 2;
    final renderedH = canvasSize.width / ar;               
    final vOff      = (renderedH - canvasSize.height) / 2;

    const double grid = 1000;
    final origL = (box[0] as num).toDouble() * canvasSize.width / grid;
    final origR = (box[2] as num).toDouble() * canvasSize.width / grid;

    final l = canvasSize.width - origR + _kOffsetX; 
    final r = canvasSize.width - origL + _kOffsetX;
    final t = (box[1] as num).toDouble() * renderedH / grid - vOff + _kOffsetY;
    final b = (box[3] as num).toDouble() * renderedH / grid - vOff + _kOffsetY;

    if (b < 0 || t > canvasSize.height) return null;

    final boxArea    = (r - l) * (b - t);
    final canvasArea = canvasSize.width * canvasSize.height;
    if (boxArea < canvasArea * _kMinBoxAreaFraction) return null;

    return (l, t, r, b);
  }

  void _reconcile() {
    if (_widgetSize == Size.zero) return;
    final canvasSize = _widgetSize;

    final incoming = [
      for (final d in widget.detections)
        (
          isTracking: false,
          box:   d['box']   as List<dynamic>,
          color: List<int>.from(d['color'] as List),
          label: d['label'] as String,
        ),
      for (final d in widget.tracking)
        (
          isTracking: true,
          box:   d['box']   as List<dynamic>,
          color: List<int>.from(d['color'] as List),
          label: '',
        ),
    ];

    final matched = <_AnimatedBox>{};

    for (final inc in incoming) {
      final coords = _toCanvas(inc.box, canvasSize);
      if (coords == null) continue;
      final (il, it, ir, ib) = coords;

      _AnimatedBox? best;
      double bestDist = double.infinity;

      for (final existing in _boxes) {
        if (matched.contains(existing)) continue;
        if (existing.isTracking != inc.isTracking) continue;

        if (!inc.isTracking) {
          if (existing.label == inc.label) { best = existing; break; }
        } else {
          final ecx  = (existing.l + existing.r) / 2;
          final ecy  = (existing.t + existing.b) / 2;
          final icx  = (il + ir) / 2;
          final icy  = (it + ib) / 2;
          final dist = math.sqrt(
              math.pow(ecx - icx, 2) + math.pow(ecy - icy, 2));
          if (dist < bestDist && dist < _kTrackingMatchRadius) {
            bestDist = dist;
            best     = existing;
          }
        }
      }

      if (best != null) {
        best.tl = il; best.tt = it; best.tr = ir; best.tb = ib;
        best.targetOpacity = 1.0;
        matched.add(best);
      } else {
        final nb = _AnimatedBox(
          l: il, t: it, r: ir, b: ib,
          color: inc.color, label: inc.label,
          isTracking: inc.isTracking,
        );
        _boxes.add(nb);
        matched.add(nb);
      }
    }

    for (final existing in _boxes) {
      if (!matched.contains(existing)) existing.targetOpacity = 0.0;
    }
  }

  void _onTick(Duration _) {
    bool dirty = false;

    for (final box in _boxes) {
      dirty |= _lf(box.l, box.tl, _kPosLerp,    0.05,  (v) => box.l = v);
      dirty |= _lf(box.t, box.tt, _kPosLerp,    0.05,  (v) => box.t = v);
      dirty |= _lf(box.r, box.tr, _kPosLerp,    0.05,  (v) => box.r = v);
      dirty |= _lf(box.b, box.tb, _kPosLerp,    0.05,  (v) => box.b = v);

      final ol = box.targetOpacity > box.opacity ? _kFadeInLerp : _kFadeOutLerp;
      dirty |= _lf(box.opacity, box.targetOpacity, ol, 0.005, (v) => box.opacity = v);

      if (box.scale < 0.999) {
        dirty |= _lf(box.scale, 1.0, _kScaleLerp, 0.001, (v) => box.scale = v);
      }
    }

    _boxes.removeWhere((b) => b.targetOpacity == 0.0 && b.opacity < 0.01);
    if (dirty) setState(() {});
  }

  bool _lf(double cur, double tgt, double t, double thresh,
      void Function(double) set) {
    final next = cur + (tgt - cur) * t;
    if ((next - cur).abs() > thresh) { set(next); return true; }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);

          if (newSize != _widgetSize) {
            _widgetSize = newSize;
            WidgetsBinding.instance.addPostFrameCallback((_) => _reconcile());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width:  widget.controller.value.previewSize!.height,
                  height: widget.controller.value.previewSize!.width,
                  child: CameraPreview(widget.controller),
                ),
              ),
              CustomPaint(painter: DetectionPainter(_boxes)),
              const Positioned(
                bottom: 0, left: 0, right: 0, height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: kBottomFade),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}