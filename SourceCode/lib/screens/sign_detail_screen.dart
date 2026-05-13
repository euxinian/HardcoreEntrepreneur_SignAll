import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/sign.dart';
import '../constants/theme.dart';

class SignDetailScreen extends StatelessWidget {
  final Sign sign;
  final VoidCallback? onTryCamera;

  const SignDetailScreen({super.key, required this.sign, this.onTryCamera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: kBgGradient),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildContent(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.15), width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
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
    final l10n        = AppLocalizations.of(context)!;
    final localeCode  = Localizations.localeOf(context).languageCode;

    final otherLocales = sign.availableLocales
        .where((code) => code != localeCode)
        .map((code) => _LocaleWord(code: code, word: sign.wordFor(code)))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            sign.wordFor(localeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: l10n.signDetailHowToSign),
          const SizedBox(height: 12),
          _GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                sign.descriptionFor(localeCode),
                style: kBodyStyle,
              ),
            ),
          ),
          if (otherLocales.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(text: l10n.signDetailTranslations),
            const SizedBox(height: 12),
            _GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (int i = 0; i < otherLocales.length; i++) ...[
                      if (i > 0) ...[
                        const SizedBox(height: 10),
                        Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.06)),
                        const SizedBox(height: 10),
                      ],
                      _TranslationRow(entry: otherLocales[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionLabel(text: l10n.signDetailColor),
          const SizedBox(height: 12),
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
                  colors: [Color(0xFF22C55E), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kGreen500.withOpacity(0.5),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.signDetailTryLive,
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
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                sign.color.withOpacity(0.18),
                const Color(0xFF064E3B).withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        CustomPaint(painter: _GridPainter(sign.color)),
        if (sign.imagePath.isNotEmpty)
          Image.asset(
            sign.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _EmojiHero(
              sign: sign,
              photoSoonLabel: l10n.signDetailPhotoSoon,
            ),
          )
        else
          _EmojiHero(sign: sign, photoSoonLabel: l10n.signDetailPhotoSoon),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF111827)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmojiHero extends StatelessWidget {
  final Sign sign;
  final String photoSoonLabel;
  const _EmojiHero({required this.sign, required this.photoSoonLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: sign.color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: sign.color.withOpacity(0.35), width: 2),
              boxShadow: [
                BoxShadow(
                    color: sign.color.withOpacity(0.3),
                    blurRadius: 28,
                    spreadRadius: 4),
              ],
            ),
            child: Center(
              child: Text(sign.emoji,
                  style: const TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            photoSoonLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color accentColor;
  _GridPainter(this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accentColor.withOpacity(0.06);
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

class _LocaleWord {
  final String code;
  final String word;
  const _LocaleWord({required this.code, required this.word});
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kGreen300, kGreen500],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: kGreen400,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _TranslationRow extends StatelessWidget {
  final _LocaleWord entry;
  const _TranslationRow({required this.entry});

  static const _langNames = {
    'en': 'English',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'ar': 'Arabic',
    'ro': 'Romanian',
    'pt': 'Portuguese',
    'it': 'Italian',
    'nl': 'Dutch',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
  };

  @override
  Widget build(BuildContext context) {
    final langName = _langNames[entry.code] ?? entry.code.toUpperCase();

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: kGreen400, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Text(
                entry.word,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                langName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorMetaCard extends StatelessWidget {
  final Color color;
  const _ColorMetaCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'
            .toUpperCase();

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hex,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    )),
                const SizedBox(height: 2),
                Text(
                  'rgb(${color.red}, ${color.green}, ${color.blue})',
                  style: kCaptionStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}