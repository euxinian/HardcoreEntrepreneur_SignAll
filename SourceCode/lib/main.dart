import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/theme.dart';
import 'screens/camera_screen.dart' as cam show CameraScreen, cameras;
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    cam.cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera init error: $e');
  }
  runApp(const SignDetrApp());
}

class SignDetrApp extends StatelessWidget {
  const SignDetrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignAll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          surface: kSurface,
          primary: kPurpleLight,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onGoToCamera: () => _goTo(1),
            onGoToLearn: () => _goTo(2),
          ),
          cam.CameraScreen(isActive: _index == 1),
          LearnScreen(onTryCamera: () {
            _goTo(1);
          }),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        onTap: _goTo,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _tabs = [
    (icon: Icons.home_rounded,     label: 'Dashboard'),
    (icon: Icons.videocam_rounded, label: 'Live Practice'),
    (icon: Icons.school_rounded,   label: 'Learning Center'),
  ];

  static const _activeColors = [kPurpleLight, kPurplePale, kPurpleLight];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: kSurface,
        border: const Border(top: BorderSide(color: Color(0x14FFFFFF), width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final active = i == currentIndex;
          final color = _activeColors[i];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 44,
                    height: 34,
                    decoration: active
                        ? BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          )
                        : null,
                    child: Icon(
                      tab.icon,
                      size: 20,
                      color: active ? color : Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: kNavLabelStyle.copyWith(
                      color: active ? color : Colors.white24,
                    ),
                    child: Text(tab.label),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
