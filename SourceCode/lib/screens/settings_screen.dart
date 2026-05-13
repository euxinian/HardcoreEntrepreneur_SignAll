import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../l10n/app_localizations.dart';

enum AppLanguage {
  english('English', '🇬🇧', 'en'),
  french('Français', '🇫🇷', 'fr'),
  german('Deutsch',  '🇩🇪', 'de');

  final String label;
  final String flag;
  final String code;
  const AppLanguage(this.label, this.flag, this.code);

  static AppLanguage fromCode(String code) => AppLanguage.values.firstWhere(
    (l) => l.code == code,
    orElse: () => AppLanguage.english,
  );
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function(AppLanguage)? onLanguageChange;

  final AppLanguage initialLanguage;

  const SettingsScreen({
    super.key,
    this.onBack,
    this.onLanguageChange,
    this.initialLanguage = AppLanguage.english,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _privacyExpanded = false;
  bool _apiExpanded     = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode      = Localizations.localeOf(context).languageCode;
    final selectedLanguage = AppLanguage.fromCode(currentCode);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(l10n),
              const SizedBox(height: 28),
              _sectionTitle(l10n.settingsLanguageSection),
              const SizedBox(height: 14),
              _buildLanguageSection(l10n, selectedLanguage),
              const SizedBox(height: 28),
              _sectionTitle(l10n.settingsPrivacySection),
              const SizedBox(height: 14),
              _buildPrivacySection(l10n),
              const SizedBox(height: 28),
              _sectionTitle(l10n.settingsAboutSection),
              const SizedBox(height: 14),
              _buildAboutSection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return Row(
      children: [
        _GlassBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: widget.onBack ?? () {},
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.settingsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(AppLocalizations l10n, AppLanguage selected) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: Color(0xFF22D3EE), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.settingsLanguageLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AppLanguage.values.map(
              (lang) => _LanguageTile(
                language: lang,
                selected: selected == lang,
                onTap: () => widget.onLanguageChange?.call(lang),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(AppLocalizations l10n) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _expandableRow(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF22D3EE),
              label: l10n.settingsPrivacyTitle,
              expanded: _privacyExpanded,
              detail: l10n.settingsPrivacyDetail,
              onTap: () =>
                  setState(() => _privacyExpanded = !_privacyExpanded),
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            _expandableRow(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF22D3EE),
              label: l10n.settingsApiTitle,
              expanded: _apiExpanded,
              detail: l10n.settingsApiDetail,
              onTap: () => setState(() => _apiExpanded = !_apiExpanded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _staticRow(Icons.info_outline_rounded, kGreen400,
                l10n.settingsVersion, '2.0.0'),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            _staticRow(Icons.hub_rounded, kGreen300,
                l10n.settingsModel, 'DETR Transformer'),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            _staticRow(Icons.group_rounded, kWarning,
                l10n.settingsTeam, 'Team SkyLine'),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      );

  Widget _divider() =>
      Container(height: 1, color: Colors.white.withOpacity(0.06));

  Widget _staticRow(
      IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withOpacity(0.42),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _expandableRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool expanded,
    required String detail,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.4), size: 20),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12, left: 32),
              child: Text(
                detail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12.5,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? kGreen500.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? kGreen400.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              language.label,
              style: TextStyle(
                color: selected ? kGreen400 : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: kGreen500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kGreen500.withOpacity(0.4), blurRadius: 6)
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
        ),
      ),
    );
  }
}