import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/signs_data.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToCamera;
  final VoidCallback onGoToLearn;
  final VoidCallback onGoToSettings;

  const HomeScreen({
    super.key,
    required this.onGoToCamera,
    required this.onGoToLearn,
    required this.onGoToSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 24),
              _buildStatsRow(l10n),
              const SizedBox(height: 16),
              _buildModelInfoCard(l10n),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Sign',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2.2,
                  height: 1.05,
                ),
              ),
              TextSpan(
                text: 'All',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: kGreen400,
                  letterSpacing: -2.2,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: kGreen400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: kGreen400.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.homeSubtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.36),
                fontSize: 12,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${kSigns.length}',
            label: l10n.statSigns,
            icon: Icons.sign_language_rounded,
            color: kGreen400,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: 'Hardcore',
            label: 'Entrepreneur 6.0',
            icon: Icons.star,
            color: const Color(0xFF34D399),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: "Team",
            label: "SkyLine",
            icon: Icons.school_rounded,
            color: const Color(0xFF2DD4BF),
          ),
        ),
      ],
    );
  }

  Widget _buildModelInfoCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kGreen500.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: kGreen500.withOpacity(0.3), width: 1),
            ),
            child: const Icon(Icons.memory_rounded,
                color: kGreen400, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeModelCard,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.homeModelCardSub,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: kGreen500.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: kGreen500.withOpacity(0.25), width: 0.8),
            ),
            child: Text(
              l10n.homeModelVersion,
              style: const TextStyle(
                color: kGreen400,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}