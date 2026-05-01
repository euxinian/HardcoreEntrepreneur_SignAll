import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/signs_data.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToCamera;
  final VoidCallback onGoToLearn;

  const HomeScreen({
    super.key,
    required this.onGoToCamera,
    required this.onGoToLearn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 10),
              _buildSubtitle(),
              const SizedBox(height: 36),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildSectionLabel('Quick Start Menu'),
              const SizedBox(height: 16),
              _buildPrimaryCard(context),
              const SizedBox(height: 14),
              _buildSecondaryCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'SignAll.\n',
            style: TextStyle(
              fontSize: 38, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -1.5, height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Welcome!',
            style: TextStyle(
              fontSize: 38, fontWeight: FontWeight.w800,
              letterSpacing: -1.5, height: 1.1,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
                ).createShader(const Rect.fromLTWH(0, 0, 220, 50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'A sign language app, integrated with a detector \nBuilt for Hardcore Entrepreneur 6.0 ',
      style: TextStyle(
        color: Colors.white38, fontSize: 13.5,
        letterSpacing: 0.1, height: 1.5,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatTile(
          value: 'DETR',
          label: 'Architecture',
          icon: Icons.hub_rounded,
          accentColor: kPurpleLight,
        ),
        const SizedBox(width: 10),
        _StatTile(
          value: '${kSigns.length}',
          label: 'Signs (DEMO)',
          icon: Icons.sign_language_rounded,
          accentColor: const Color(0xFF00C896),
        ),
        const SizedBox(width: 10),
        const _StatTile(
          value: 'Team',
          label: 'SkyLine',
          icon: Icons.group,
          accentColor: Color(0xFFFFB400),
        ),
      ],
    );
  }

  Widget _buildPrimaryCard(BuildContext context) {
    return GestureDetector(
      onTap: onGoToCamera,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6D28D9), Color(0xFFA855F7)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Live Practice',
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  SizedBox(height: 6),
                  Text('Practice signs with the help of our DETR model',
                    style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.4)),
                ],
              ),
            ),
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(BuildContext context) {
    return GestureDetector(
      onTap: onGoToLearn,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kBorder, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: kPurpleGlow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_rounded, color: kPurplePale, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Learning Center',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                  SizedBox(height: 3),
                  Text('Information about how to perform a specific sign',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: kPurplePale, fontSize: 10.5,
        fontWeight: FontWeight.w700, letterSpacing: 1.6,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.18), width: 0.8),
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: accentColor, size: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                  style: TextStyle(
                    color: accentColor, fontSize: 17,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5,
                  )),
                Text(label,
                  style: const TextStyle(
                    color: Colors.white38, fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
