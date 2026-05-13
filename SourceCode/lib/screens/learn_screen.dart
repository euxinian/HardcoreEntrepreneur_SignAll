import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/signs_data.dart';
import '../constants/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/sign.dart';
import 'sign_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  final VoidCallback? onTryCamera;
  final VoidCallback? onBack;
  const LearnScreen({super.key, this.onTryCamera, this.onBack});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _search = TextEditingController();
  String _query = '';

  List<Sign> _filtered(String localeCode) {
    final q = _query.toLowerCase();
    if (q.isEmpty) return kSigns;
    return kSigns.where((s) {
      if (s.displayName.toLowerCase().contains(q)) return true;
      for (final code in s.availableLocales) {
        if (s.wordFor(code).toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final signs = _filtered(localeCode);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i >= signs.length) return null;
                    return _SignRow(
                      sign: signs[i],
                      index: i,
                      localeCode: localeCode,
                      onTryCamera: widget.onTryCamera,
                    );
                  },
                  childCount: signs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BackButton(onTap: widget.onBack ?? () {}),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.learnTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: kGreen500.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: kGreen400.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      '${kSigns.length} ${l10n.statSigns.toLowerCase()}',
                      style: const TextStyle(
                        color: kGreen400,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.10), width: 1),
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: kGreen500,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintText: l10n.learnSearchHint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SignRow extends StatefulWidget {
  final Sign sign;
  final int index;
  final String localeCode;
  final VoidCallback? onTryCamera;

  const _SignRow({
    required this.sign,
    required this.index,
    required this.localeCode,
    this.onTryCamera,
  });

  @override
  State<_SignRow> createState() => _SignRowState();
}

class _SignRowState extends State<_SignRow> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final color = widget.sign.color;
    final localizedWord = widget.sign.wordFor(widget.localeCode);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => SignDetailScreen(
              sign: widget.sign,
              onTryCamera: widget.onTryCamera,
            ),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        );
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                        border: Border(
                          right: BorderSide(
                              color: color.withOpacity(0.25), width: 1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.sign.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.index + 1}',
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          localizedWord,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 6)
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.22),
                              size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 15),
          ),
        ),
      ),
    );
  }
}