import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/signs_data.dart';
import '../screens/sign_detail_screen.dart';


class DetectionPanel extends StatelessWidget {
  final Map<String, dynamic>? top;

  final List<dynamic> secondary;

  final String labelKey;

  const DetectionPanel({
    super.key,
    required this.top,
    required this.secondary,
    required this.labelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(
          top: BorderSide(color: Color(0x0AFFFFFF), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: top == null
            ? const IdlePanel(key: ValueKey('idle'))
            : ActivePanel(
                key: ValueKey(labelKey),
                det: top!,
                secondary: secondary,
              ),
      ),
    );
  }
}

class IdlePanel extends StatelessWidget {
  const IdlePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder, width: 0.8),
          ),
          child: const Icon(
            Icons.sign_language_rounded,
            color: Colors.white24,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No sign detected...',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Show a sign to the camera',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 11.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActivePanel extends StatelessWidget {
  final Map<String, dynamic> det;
  final List<dynamic> secondary;

  const ActivePanel({
    super.key,
    required this.det,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = (det['confidence'] as num).toDouble();
    final rawLabel = det['label'] as String;
    final label = rawLabel.replaceAll('_', ' ');
    final List<dynamic> rgb = det['color'];
    final color = Color.fromRGBO(
      rgb[0] as int, rgb[1] as int, rgb[2] as int, 1.0);

    // Try to find the matching Sign for the info button
    final sign = signByName(rawLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    color: color.withOpacity(0.32), width: 0.9),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),

            if (sign != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignDetailScreen(sign: sign),
                  ),
                ),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withOpacity(0.22), width: 0.8),
                  ),
                  child: Icon(Icons.info_outline_rounded,
                      color: color.withOpacity(0.7), size: 16),
                ),
              ),
            ],

            const Spacer(),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: confidence),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text(
                '${(v * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: confidence.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Stack(
            children: [
              Container(
                height: 3.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: secondary.map((d) {
              final List<dynamic> c = d['color'];
              final col = Color.fromRGBO(
                c[0] as int, c[1] as int, c[2] as int, 1.0);
              final lbl = (d['label'] as String).replaceAll('_', ' ');
              final conf =
                  ((d['confidence'] as num).toDouble() * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: col.withOpacity(0.22), width: 0.7),
                  ),
                  child: Text(
                    '$lbl  $conf%',
                    style: TextStyle(
                      color: col,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
