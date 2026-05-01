import 'package:flutter/material.dart';

const Color kBg       = Color(0xFF08080F); 
const Color kSurface  = Color(0xFF111120); 
const Color kSurface2 = Color(0xFF1A1A2E); 
const Color kBorder   = Color(0x20A855F7); 
const Color kBorder2  = Color(0x10FFFFFF); 

const Color kPurple      = Color(0xFF7C3AED);
const Color kPurpleLight = Color(0xFFA855F7); 
const Color kPurplePale  = Color(0xFFC084FC); 
const Color kPurpleGlow  = Color(0x337C3AED); 


  const List<Color> kSignColors = [
  Color(0xFFFF5E5B), 
  Color(0xFF00C896), 
  Color(0xFFFFB400), 
  Color(0xFF6495ED), 
  Color(0xFFDC5ADC), 
  Color(0xFF00D2D2), 
];


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
  color: Colors.white38, letterSpacing: 0.1,
);

const TextStyle kBodyStyle = TextStyle(
  fontSize: 14.5, fontWeight: FontWeight.w400,
  color: Colors.white70, height: 1.65,
);

const TextStyle kNavLabelStyle = TextStyle(
  fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.1,
);

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
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF111120)],
  ),
);

const LinearGradient kBottomFade = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.transparent, Color(0xCC08080F)],
);

const LinearGradient kPurpleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
);
