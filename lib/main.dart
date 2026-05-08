import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemNavigator.pop()
import 'package:form_app_27_3_2026/app_theme.dart';
import 'package:form_app_27_3_2026/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'; // Added
import 'package:package_info_plus/package_info_plus.dart'; // Added
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Catch all errors thrown by the Flutter framework
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch all asynchronous errors (like API failures or hidden Dart errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Clear any existing session to ensure logout on app restart/close
  // Preserve _formRecovery_* keys so process-death recovery still works
  final prefs = await SharedPreferences.getInstance();
  final allKeys = prefs.getKeys().toList();
  for (final key in allKeys) {
    if (!key.startsWith('_formRecovery_')) {
      await prefs.remove(key);
    }
  }

  runApp(const AvsServiceApp());
}

class AvsServiceApp extends StatefulWidget {
  const AvsServiceApp({super.key});

  @override
  State<AvsServiceApp> createState() => _AvsServiceAppState();
}

class _AvsServiceAppState extends State<AvsServiceApp>
    with WidgetsBindingObserver {
  Timer? _timer;

  /// Tracks when the current timer was started so we can compute remaining
  /// time if the app is paused (e.g. camera / cropper opens).
  DateTime? _timerStartedAt;

  /// The full inactivity duration before auto-logout.
  static const Duration _inactivityDuration = Duration(minutes: 15);

  /// Remaining time when the app went to background.  Stored so we can
  /// resume with whatever was left instead of restarting the full 15 min.
  Duration? _remainingWhenPaused;

  void _startInactivityTimer([Duration? customDuration]) {
    _timer?.cancel();
    final duration = customDuration ?? _inactivityDuration;
    _timerStartedAt = DateTime.now();
    _remainingWhenPaused = null;
    _timer = Timer(duration, () {
      _logoutUser();
    });
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().toList();
    for (final key in allKeys) {
      if (!key.startsWith('_formRecovery_')) {
        await prefs.remove(key);
      }
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleUserInteraction([_]) {
    _startInactivityTimer();
  }

  // ── Lifecycle observer: pause / resume timer around native activities ──

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background (camera, cropper, permission dialog, etc.)
      // Pause the timer so background time is NOT counted as inactivity.
      if (_timer != null && _timer!.isActive && _timerStartedAt != null) {
        final elapsed = DateTime.now().difference(_timerStartedAt!);
        _remainingWhenPaused = _inactivityDuration - elapsed;
        if (_remainingWhenPaused!.isNegative) {
          _remainingWhenPaused = Duration.zero;
        }
        _timer?.cancel();
        debugPrint(
          '[INACTIVITY] Timer paused – ${_remainingWhenPaused!.inSeconds}s remaining',
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      // App returned to foreground.
      // The user just came back from an active interaction (camera, etc.),
      // so reset the full 15-minute timer.
      debugPrint('[INACTIVITY] App resumed – resetting inactivity timer');
      _startInactivityTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'AVS CoopSeva 360',
        theme: AppTheme.lightTheme,
        // CHANGED: Boot into the Splash Screen first to check the version!
        home: const SplashScreen(),
      ),
    );
  }
}

// ============================================================================
// NEW: Splash Screen & Version Checking Logic
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Force it to check Firebase instantly every time the app opens
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );

      await remoteConfig.fetchAndActivate();

      // Get the minimum version allowed from Firebase Console
      // (Make sure you create a parameter named exactly 'minimum_required_version' in Firebase)
      int requiredBuildNumber = remoteConfig.getInt('minimum_required_version');

      // Get the current build number of the APK
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (currentBuildNumber < requiredBuildNumber) {
        _showForceUpdateDialog();
      } else {
        _goToLogin();
      }
    } catch (e) {
      // If there is no internet, or Firebase is blocked, just let them in normally
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot tap outside to dismiss
      builder: (context) {
        return PopScope(
          canPop: false, // Disables the Android hardware back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.system_update, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "Update Required",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "You are using an outdated version of CoopSeva 360.\n\n"
              "Please uninstall this app and download the latest APK from the team WhatsApp group to continue working.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Closes the app completely
                  SystemNavigator.pop();
                },
                child: const Text(
                  "Close App",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1E4A), // App theme Navy Blue
      body: Center(
        // Just a simple loading spinner while it checks Firebase
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:form_app_27_3_2026/app_theme.dart';
// import 'package:form_app_27_3_2026/login_screen.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart'; // This is the file your terminal command just created!

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Initialize Firebase using the generated options
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // 3. Catch all errors thrown by the Flutter framework
//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

//   // 4. Catch all asynchronous errors (like API failures or hidden Dart errors)
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };

//   // Clear any existing session to ensure logout on app restart/close
//   // Preserve _formRecovery_* keys so process-death recovery still works
//   final prefs = await SharedPreferences.getInstance();
//   final allKeys = prefs.getKeys().toList();
//   for (final key in allKeys) {
//     if (!key.startsWith('_formRecovery_')) {
//       await prefs.remove(key);
//     }
//   }

//   runApp(const AvsServiceApp());
// }

// class AvsServiceApp extends StatefulWidget {
//   const AvsServiceApp({super.key});

//   @override
//   State<AvsServiceApp> createState() => _AvsServiceAppState();
// }

// class _AvsServiceAppState extends State<AvsServiceApp> {
//   Timer? _timer;

//   void _startInactivityTimer() {
//     _timer?.cancel();
//     _timer = Timer(const Duration(minutes: 15), () {
//       _logoutUser();
//     });
//   }

//   Future<void> _logoutUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Preserve _formRecovery_* keys so process-death recovery still works
//     final allKeys = prefs.getKeys().toList();
//     for (final key in allKeys) {
//       if (!key.startsWith('_formRecovery_')) {
//         await prefs.remove(key);
//       }
//     }
//     navigatorKey.currentState?.pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   void _handleUserInteraction([_]) {
//     _startInactivityTimer();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _startInactivityTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       onPointerDown: _handleUserInteraction,
//       onPointerMove: _handleUserInteraction,
//       onPointerUp: _handleUserInteraction,
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         debugShowCheckedModeBanner: false,
//         title: 'AVS CoopSeva 360',
//         theme: AppTheme.lightTheme,
//         home: const LoginScreen(),
//       ),
//     );
//   }
// }
