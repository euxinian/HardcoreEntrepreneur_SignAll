import 'package:flutter/material.dart';

// ── Background ──────────────────────────────────────────────────────────────
const Color kBg = Color(0xFF111827);

// ── Surfaces ────────────────────────────────────────────────────────────────
const Color kSurface  = Color(0x0DFFFFFF); // white 5%
const Color kSurface2 = Color(0x1AFFFFFF); // white 10%
const Color kBorder   = Color(0x1AFFFFFF); // white 10%
const Color kBorder2  = Color(0x0DFFFFFF); // white 5%

// ── Emerald accent ──────────────────────────────────────────────────────────
const Color kGreen500 = Color(0xFF10B981); // primary accent
const Color kGreen400 = Color(0xFF34D399); // bright accent
const Color kGreen300 = Color(0xFF4ADE80); // green-400

// ── Semantic ────────────────────────────────────────────────────────────────
const Color kWarning = Color(0xFFFBBF24); // yellow-400
const Color kError   = Color(0xFFF87171); // red-400

// ── Text ────────────────────────────────────────────────────────────────────
const Color kTextPrimary   = Colors.white;
const Color kTextMuted     = Color(0x99FFFFFF); // 60%
const Color kTextVeryMuted = Color(0x4DFFFFFF); // 30%

// ── Legacy aliases (kept so camera/detection files compile) ─────────────────
const Color kPurple      = Color(0xFF10B981);
const Color kPurpleLight = Color(0xFF34D399);
const Color kPurplePale  = Color(0xFF4ADE80);
const Color kPurpleGlow  = Color(0x1A10B981);

// ── Background gradient ─────────────────────────────────────────────────────
const LinearGradient kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF111827), Color(0xFF064E3B), Color(0xFF111827)],
);

// ── Bottom fade (used by detection_painter) ──────────────────────────────────
const LinearGradient kBottomFade = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.transparent, Color(0xCC111827)],
);

// ── Sign colours (unchanged) ─────────────────────────────────────────────────
const List<Color> kSignColors = [
  Color(0xFFFF5E5B),
  Color(0xFF00C896),
  Color(0xFFFFB400),
  Color(0xFF6495ED),
  Color(0xFFDC5ADC),
  Color(0xFF00D2D2),
];

// ── Text styles ──────────────────────────────────────────────────────────────
const TextStyle kDisplayStyle = TextStyle(
  fontSize: 38, fontWeight: FontWeight.w800,
  color: Colors.white, letterSpacing: -1.2, height: 1.1,
);

const TextStyle kHeadingStyle = TextStyle(
  fontSize: 20, fontWeight: FontWeight.w700,
  color: Colors.white, letterSpacing: -0.5,
);

const TextStyle kCardTitleStyle = TextStyle(
  fontSize: 15, fontWeight: FontWeight.w700,
  color: Colors.white, letterSpacing: -0.2,
);

const TextStyle kCaptionStyle = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w500,
  color: Color(0x99FFFFFF), letterSpacing: 0.1,
);

const TextStyle kBodyStyle = TextStyle(
  fontSize: 14.5, fontWeight: FontWeight.w400,
  color: Color(0xB3FFFFFF), height: 1.65,
);

const TextStyle kNavLabelStyle = TextStyle(
  fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.1,
);

// ── Glassmorphism surface decoration ─────────────────────────────────────────
BoxDecoration glassDecoration({double radius = 16}) => BoxDecoration(
  color: kSurface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: kBorder, width: 1),
);

// ── Legacy helpers ────────────────────────────────────────────────────────────
BoxDecoration cardDecoration({Color? accent}) => BoxDecoration(
  color: kSurface,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: accent != null ? accent.withOpacity(0.18) : kBorder,
    width: 0.8,
  ),
);

BoxDecoration purpleCardDecoration() => BoxDecoration(
  color: kSurface2,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: kBorder, width: 0.8),
);

const LinearGradient kPurpleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF10B981), Color(0xFF059669)],
);