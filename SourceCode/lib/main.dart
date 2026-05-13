import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'constants/theme.dart';
import 'screens/camera_screen.dart' as cam show CameraScreen, cameras;
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/settings_screen.dart';

const _kLocaleKey = 'app_locale';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs     = await SharedPreferences.getInstance();
  final savedCode = prefs.getString(_kLocaleKey) ?? 'en';
  final initialLanguage = AppLanguage.values.firstWhere(
    (l) => l.code == savedCode,
    orElse: () => AppLanguage.english,
  );

  try {
    cam.cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera init error: $e');
  }

  runApp(SignDetrApp(initialLanguage: initialLanguage));
}

class SignDetrApp extends StatefulWidget {
  final AppLanguage initialLanguage;
  const SignDetrApp({super.key, required this.initialLanguage});

  @override
  State<SignDetrApp> createState() => _SignDetrAppState();
}

class _SignDetrAppState extends State<SignDetrApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.initialLanguage.code);
  }

  Future<void> _onLanguageChange(AppLanguage lang) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, lang.code);

    if (mounted) setState(() => _locale = Locale(lang.code));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignAll',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          surface: kSurface,
          primary: kGreen500,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: MainShell(
        initialLanguage: widget.initialLanguage,
        onLanguageChange: _onLanguageChange,
      ),
    );
  }
}


class MainShell extends StatefulWidget {
  final AppLanguage initialLanguage;
  final void Function(AppLanguage) onLanguageChange;

  const MainShell({
    super.key,
    required this.initialLanguage,
    required this.onLanguageChange,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);
  void _goHome() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: kBgGradient),
            ),
          ),

          _GlowBlob(
            left: -60, top: s.height * 0.12, size: 280,
            opacity: const (0.05, 0.13),
            delay: Duration.zero,
          ),
          _GlowBlob(
            left: s.width - 180, top: s.height * 0.58, size: 280,
            opacity: const (0.05, 0.13),
            delay: const Duration(seconds: 1),
          ),
          _GlowBlob(
            left: s.width * 0.3, top: -80, size: 340,
            opacity: const (0.03, 0.09),
            delay: const Duration(milliseconds: 600),
            duration: const Duration(seconds: 5),
          ),
          _GlowBlob(
            left: -40, top: s.height * 0.70, size: 220,
            opacity: const (0.04, 0.10),
            delay: const Duration(milliseconds: 1400),
            duration: const Duration(seconds: 4),
          ),
          _GlowBlob(
            left: s.width - 100, top: s.height * 0.28, size: 180,
            opacity: const (0.03, 0.08),
            delay: const Duration(milliseconds: 900),
            duration: const Duration(seconds: 6),
          ),

          if (_index == 0)
            HomeScreen(
              onGoToCamera:   () => _goTo(1),
              onGoToLearn:    () => _goTo(2),
              onGoToSettings: () => _goTo(3),
            ),
          if (_index == 1)
            cam.CameraScreen(isActive: true, onBack: _goHome),
          if (_index == 2)
            LearnScreen(onTryCamera: () => _goTo(1), onBack: _goHome),
          if (_index == 3)
            SettingsScreen(
              initialLanguage: widget.initialLanguage,
              onBack: _goHome,
              onLanguageChange: widget.onLanguageChange,
            ),

          if (_index == 0)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: _WheelNav(
                  onCamera:   () => _goTo(1),
                  onLearn:    () => _goTo(2),
                  onSettings: () => _goTo(3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatefulWidget {
  final double top;
  final double left;
  final double size;
  final (double, double) opacity;
  final Duration delay;
  final Duration duration;

  const _GlowBlob({
    required this.top,
    required this.left,
    this.size = 280,
    this.opacity = const (0.05, 0.13),
    this.delay = Duration.zero,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<_GlowBlob> createState() => _GlowBlobState();
}

class _GlowBlobState extends State<_GlowBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween(begin: widget.opacity.$1, end: widget.opacity.$2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: kGreen500.withOpacity(_anim.value),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelNav extends StatefulWidget {
  final VoidCallback onCamera;
  final VoidCallback onLearn;
  final VoidCallback onSettings;

  const _WheelNav({
    required this.onCamera,
    required this.onLearn,
    required this.onSettings,
  });

  @override
  State<_WheelNav> createState() => _WheelNavState();
}

class _WheelNavState extends State<_WheelNav> with TickerProviderStateMixin {
  bool _open = false;

  late final AnimationController _expandCtrl;
  late final AnimationController _pingCtrl;

  static const _items = [
    (angle: -90.0, label: 'Live',     icon: Icons.videocam_rounded,
     colors: <Color>[Color(0xFF4ADE80), Color(0xFF10B981)]),
    (angle:  30.0, label: 'Learn',    icon: Icons.school_rounded,
     colors: <Color>[Color(0xFF34D399), Color(0xFF14B8A6)]),
    (angle: 150.0, label: 'Settings', icon: Icons.settings_rounded,
     colors: <Color>[Color(0xFF2DD4BF), Color(0xFF06B6D4)]),
  ];

  static const double _radius = 120.0;
  late final List<Animation<double>> _itemProgress;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _pingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _itemProgress = List.generate(3, (i) {
      final start = i * 0.12;
      return CurvedAnimation(
        parent: _expandCtrl,
        curve: Interval(start, math.min(start + 0.75, 1.0),
            curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _pingCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  void _onItemTap(int i) {
    _toggle();
    Future.delayed(const Duration(milliseconds: 1), () {
      if (i == 0) widget.onCamera();
      if (i == 1) widget.onLearn();
      if (i == 2) widget.onSettings();
    });
  }

  Offset _polar(double deg) {
    final r = deg * math.pi / 180;
    return Offset(math.cos(r) * _radius, math.sin(r) * _radius);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 500,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _pingCtrl,
              builder: (_, __) {
                final t          = _pingCtrl.value;
                final maxScale   = _open ? 4.2  : 3.25;
                final maxOpacity = _open ? 0.25 : 0.20;
                return Transform.scale(
                  scale: 1.0 + t * (maxScale - 1.0),
                  child: Opacity(
                    opacity: (maxOpacity * (1.0 - t)).clamp(0.0, 1.0),
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: _open ? 5.5 : 3.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          ...List.generate(3, (i) {
            final dest = _polar(_items[i].angle);
            return AnimatedBuilder(
              animation: _itemProgress[i],
              builder: (_, __) {
                final t = _itemProgress[i].value;
                return Transform.translate(
                  offset: Offset(dest.dx * t, dest.dy * t),
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: t.clamp(0.0, 1.0),
                      child: _WheelItem(
                        icon:     _items[i].icon,
                        label:    _items[i].label,
                        gradient: _items[i].colors,
                        onTap:    () => _onItemTap(i),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          _CenterButton(open: _open, onTap: _toggle),
        ],
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  final bool open;
  final VoidCallback onTap;
  const _CenterButton({required this.open, required this.onTap});

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _scale = 0.90 * 1.32),
      onTapUp:     (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: ()  => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF22C55E), Color(0xFF10B981)],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.open
                    ? const Color(0xFF10B981).withOpacity(0.65)
                    : const Color(0xFF10B981).withOpacity(0.35),
                blurRadius: widget.open ? 50 : 28,
                offset: widget.open ? Offset.zero : const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            switchInCurve:  Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: RotationTransition(
                turns: Tween(begin: -0.15, end: 0.0).animate(anim),
                child: child,
              ),
            ),
            child: widget.open
                ? const Icon(Icons.close_rounded,
                    key: ValueKey('close'), color: Colors.white, size: 30)
                : const _ClosedIcon(key: ValueKey('ring')),
          ),
        ),
      ),
    );
  }
}

class _ClosedIcon extends StatelessWidget {
  const _ClosedIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _WheelItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _WheelItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_WheelItem> createState() => _WheelItemState();
}

class _WheelItemState extends State<_WheelItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _scale = 0.88),
      onTapUp:     (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: ()  => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62, height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 6),
            Text(widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                )),
          ],
        ),
      ),
    );
  }
}