import 'package:flutter/material.dart';
import '../models/sign.dart';
import '../constants/theme.dart';

class SignDetailScreen extends StatelessWidget {
  final Sign sign;
  final VoidCallback? onTryCamera;

  const SignDetailScreen({super.key, required this.sign, this.onTryCamera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: kBg,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12, width: 0.8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroArea(sign: sign),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(sign.name.replaceAll('_', ' '),
            style: const TextStyle(color: Colors.white, fontSize: 40,
                fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.05)),
          const SizedBox(height: 28),
          _SectionLabel(color: kPurpleLight, text: 'How to sign it'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 0.8),
            ),
            child: Text(sign.description, style: kBodyStyle),
          ),
          const SizedBox(height: 24),
          _SectionLabel(color: kPurpleLight, text: 'Color'),
          const SizedBox(height: 14),
          _ColorMetaCard(color: sign.color),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              onTryCamera?.call();
            },
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6D28D9), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: kPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Try in practice mode',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArea extends StatelessWidget {
  final Sign sign;
  const _HeroArea({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                sign.color.withOpacity(0.15),
                kPurple.withOpacity(0.08),
                kBg,
              ],
            ),
          ),
        ),
        CustomPaint(painter: _GridPainter()),
        if (sign.imagePath.isNotEmpty)
          Image.asset(sign.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _EmojiHero(sign: sign))
        else
          _EmojiHero(sign: sign),
        const Positioned(
          bottom: 0, left: 0, right: 0, height: 80,
          child: DecoratedBox(decoration: BoxDecoration(gradient: kBottomFade)),
        ),
      ],
    );
  }
}

class _EmojiHero extends StatelessWidget {
  final Sign sign;
  const _EmojiHero({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: sign.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: sign.color.withOpacity(0.25), width: 1),
            ),
            child: Center(child: Text(sign.emoji,
                style: const TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 10),
          Text('Photo coming soon',
            style: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 11, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x08A855F7);
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _SectionLabel extends StatelessWidget {
  final Color color;
  final String text;
  const _SectionLabel({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 14,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.5,
            fontWeight: FontWeight.w700, letterSpacing: 1.4)),
    ]);
  }
}

class _ColorMetaCard extends StatelessWidget {
  final Color color;
  const _ColorMetaCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final hex = '#'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 0.8),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
          ),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hex,
            style: const TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          const SizedBox(height: 2),
          Text('rgb(${color.red}, ${color.green}, ${color.blue})',
            style: kCaptionStyle),
        ]),
      ]),
    );
  }
}
