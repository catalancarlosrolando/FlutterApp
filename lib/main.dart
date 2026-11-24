import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/models/app_user.dart';
import 'package:flutter_application/src/pages/MainNavigationPage.dart';
import 'package:flutter_application/src/pages/add_exercise_page.dart';
import 'package:flutter_application/src/pages/admin_panel_page.dart';
import 'package:flutter_application/src/pages/biometric_lock_page.dart';
import 'package:flutter_application/src/pages/login_page.dart';
import 'package:flutter_application/src/pages/register_page.dart';
import 'package:flutter_application/src/pages/rejected_page.dart';
import 'package:flutter_application/src/pages/settings_page.dart';
import 'package:flutter_application/src/pages/waiting_approval_page.dart';
import 'package:flutter_application/src/services/auth_gate_notifier.dart';
import 'package:flutter_application/src/theme/color_sheme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize(
    serverClientId:
        'firebase-adminsdk-fbsvc@flutter-50644.iam.gserviceaccount.com',
  );

  runApp(const FitAccessApp());
}

/// Notificador global para alternar tema claro / oscuro en la app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class FitAccessApp extends StatefulWidget {
  const FitAccessApp({super.key});

  @override
  State<FitAccessApp> createState() => _FitAccessAppState();
}

class _FitAccessAppState extends State<FitAccessApp> {
  late final AuthGateNotifier _authGate;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authGate = AuthGateNotifier();
    _router = GoRouter(
      initialLocation: '/loading',
      refreshListenable: _authGate,
      redirect: (context, state) {
        final loc = state.matchedLocation;

        if (_authGate.isLoading) {
          return loc == '/loading' ? null : '/loading';
        }

        if (!_authGate.isSignedIn) {
          if (loc == '/login' || loc == '/register') return null;
          return '/login';
        }

        if (_authGate.status == UserStatus.pending) {
          return loc == '/waiting' ? null : '/waiting';
        }

        if (_authGate.status == UserStatus.rejected) {
          return loc == '/rejected' ? null : '/rejected';
        }

        // status == approved
        if (_authGate.needsBiometricUnlock) {
          return loc == '/biometric-lock' ? null : '/biometric-lock';
        }

        if (loc == '/admin' && !_authGate.isAdmin) {
          return '/home';
        }

        const gateRoutes = {
          '/',
          '/loading',
          '/login',
          '/register',
          '/waiting',
          '/rejected',
          '/biometric-lock',
        };
        if (gateRoutes.contains(loc)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(authGate: _authGate),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterPage(authGate: _authGate),
        ),
        GoRoute(
          path: '/waiting',
          builder: (context, state) => const WaitingApprovalPage(),
        ),
        GoRoute(
          path: '/rejected',
          builder: (context, state) => const RejectedPage(),
        ),
        GoRoute(
          path: '/biometric-lock',
          builder: (context, state) => BiometricLockPage(authGate: _authGate),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => MainNavigationPage(
            uid: _authGate.firebaseUser?.uid ?? '',
          ),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminPanelPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsPage(authGate: _authGate),
        ),
        GoRoute(
          path: '/addEjercicio',
          builder: (context, state) => const AddExercisePage(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authGate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          title: 'FitAccess',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            scaffoldBackgroundColor: lightColorScheme.surface,
            textTheme: GoogleFonts.nunitoTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            scaffoldBackgroundColor: darkColorScheme.surface,
            textTheme: GoogleFonts.nunitoTextTheme(),
          ),
          themeMode: currentMode,
          routerConfig: _router,
        );
      },
    );
  }
}
