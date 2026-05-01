import 'package:flutter/material.dart';
import '../constants/signs_data.dart';
import '../constants/theme.dart';
import '../models/sign.dart';
import 'sign_detail_screen.dart';

class LearnScreen extends StatelessWidget {
  final VoidCallback? onTryCamera;
  const LearnScreen({super.key, this.onTryCamera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _LearnHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _SignRow(
                    sign: kSigns[i],
                    index: i,
                    onTryCamera: onTryCamera,
                  ),
                  childCount: kSigns.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kPurpleGlow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder, width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: kPurplePale, size: 12),
                SizedBox(width: 5),
                Text('Guide for learning and practicing signs',
                  style: TextStyle(color: kPurplePale, fontSize: 11,
                      fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Learning\nCenter',
            style: TextStyle(
              color: Colors.white, fontSize: 42,
              fontWeight: FontWeight.w900, letterSpacing: -1.8, height: 1.0,
            )),
          const SizedBox(height: 24),
          _ProgressStrip(),
        ],
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: kSigns.map((s) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(color: s.color.withOpacity(0.4), blurRadius: 4)],
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(width: 12),
          Text('${kSigns.length} Signs',
            style: const TextStyle(
              color: kPurplePale, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SignRow extends StatelessWidget {
  final Sign sign;
  final int index;
  final VoidCallback? onTryCamera;

  const _SignRow({required this.sign, required this.index, this.onTryCamera});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) =>
              SignDetailScreen(sign: sign, onTryCamera: onTryCamera),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sign.color.withOpacity(0.14), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: sign.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: sign.color.withOpacity(0.22), width: 0.8),
              ),
              alignment: Alignment.center,
              child: Text('${index + 1}',
                style: TextStyle(
                  color: sign.color, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 14),
            Text(sign.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sign.name.replaceAll('_', ' '),
                    style: const TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  Text(sign.translation,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(sign.secondTranslation,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: sign.color, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: sign.color.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white24, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
