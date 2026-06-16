import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

import 'models/alert.dart';
import 'services/backend_api.dart';
import 'models/profile.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/emergency_actions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';
import 'widgets/bottom_nav.dart';

enum AppView { home, alerts, alertDetail, emergencyActions, profile, settings }

class SafeGuardApp extends StatelessWidget {
  const SafeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(color: AppColors.text),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _usernameKey = 'signup_username';
  static const _passwordKey = 'signup_password';

  bool _isAuthenticated = false;
  bool _showSignup = false;
  bool _isLoadingCredentials = true;
  String _signupSuccess = '';
  String _loginError = '';
  SignupCredentials? _credentials;
  Profile _profile = Profile.defaultProfile;
  AppView _view = AppView.home;
  AppTab _tab = AppTab.home;
  AlertStatus? _alertFilter;
  int? _selectedAlertId;

  final Map<String, bool> _notifications = {
    'fallDetected': true,
    'inactivity': true,
    'wandering': true,
  };

  List<Alert> _alerts = [
    // initial placeholder; will be replaced by backend fetch if available
  ];

  Future<void> _loadAlertsFromBackend() async {
    try {
      // Replace `user_1` with real signed-in user id when auth available
      final alerts = await BackendApi.fetchAlertsForUser('user_1');
      if (!mounted) return;
      setState(() => _alerts = alerts);
    } catch (e) {
      // keep built-in sample alerts on error
      if (!mounted) return;
      setState(() {
        _alerts = [
          Alert(
            id: 1,
            type: 'Inactivity Alert',
            status: AlertStatus.pending,
            severity: AlertSeverity.medium,
            occurredAt: DateTime.parse('2026-04-25T23:02:00'),
            incidentDetail: 'Inactivity detected in 2+ hours.',
          ),
          Alert(
            id: 2,
            type: 'Fall Detected',
            status: AlertStatus.pending,
            severity: AlertSeverity.high,
            occurredAt: DateTime.parse('2026-04-25T21:44:00'),
            incidentDetail:
                'Fall detected in the hallway. Subject remained on floor.',
          ),
          Alert(
            id: 3,
            type: 'Wandering Alert',
            status: AlertStatus.pending,
            severity: AlertSeverity.high,
            occurredAt: DateTime.parse('2026-04-25T20:16:00'),
            incidentDetail: 'Repeated pacing detected in an unusual pattern.',
          ),
        ];
      });
    }
  }

  Alert? get _activeAlert {
    for (final alert in _alerts) {
      if (alert.id == _selectedAlertId) {
        return alert;
      }
    }
    return null;
  }

  DateTime? get _latestAlertTime {
    if (_alerts.isEmpty) {
      return null;
    }
    return _alerts.reduce((latest, current) {
      return current.occurredAt.isAfter(latest.occurredAt) ? current : latest;
    }).occurredAt;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _loadAlertsFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCredentials) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!_isAuthenticated) {
      return _showSignup
          ? SignupScreen(
              onBackToLogin: () => setState(() => _showSignup = false),
              onSubmit: _saveSignupCredentials,
            )
          : LoginScreen(
              successMessage: _signupSuccess,
              errorMessage: _loginError,
              onSignIn: _signIn,
              onOpenSignUp: () => setState(() {
                _signupSuccess = '';
                _loginError = '';
                _showSignup = true;
              }),
            );
    }

    final showBottomNav = _view == AppView.home ||
        _view == AppView.alerts ||
        _view == AppView.settings;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildCurrentScreen()),
            if (showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNav(tab: _tab, onChange: _changeTab),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_view) {
      case AppView.home:
        return HomeScreen(
          alertsCount: _alerts
              .where((item) => item.status == AlertStatus.pending)
              .length,
          profile: _profile,
          lastActivityTime: _latestAlertTime,
          onBack: _signOut,
          onEmergencyClick: () {
            _openPhoneDialer();
          },
          onCall1990Click: () {
            _openPhoneDialer('1990');
          },
          onAlertsClick: () => _changeTab(AppTab.alerts),
          onOpenProfile: () => setState(() => _view = AppView.profile),
        );
      case AppView.alerts:
        return AlertsScreen(
          alerts: _alerts,
          filter: _alertFilter,
          onBack: () => _changeTab(AppTab.home),
          onFilterChange: (filter) => setState(() => _alertFilter = filter),
          onOpenAlert: (id) => setState(() {
            _selectedAlertId = id;
            _view = AppView.alertDetail;
          }),
        );
      case AppView.alertDetail:
        final alert = _activeAlert;
        if (alert == null) {
          return AlertsScreen(
            alerts: _alerts,
            filter: _alertFilter,
            onBack: () => _changeTab(AppTab.home),
            onFilterChange: (filter) => setState(() => _alertFilter = filter),
            onOpenAlert: (id) => setState(() => _selectedAlertId = id),
          );
        }
        return AlertDetailScreen(
          alert: alert,
          onBack: () => setState(() => _view = AppView.alerts),
          onHandleEmergency: () =>
              setState(() => _view = AppView.emergencyActions),
          onStatusChecked: () {
            setState(() {
              _alerts = _alerts
                  .map(
                    (item) => item.id == alert.id
                        ? item.copyWith(status: AlertStatus.checked)
                        : item,
                  )
                  .toList();
            });
          },
        );
      case AppView.emergencyActions:
        return EmergencyActionsScreen(
          emergencyContactNumber: _profile.emergencyContacts.isEmpty
              ? ''
              : _profile.emergencyContacts.first.phone,
          onBack: () => setState(() => _view = AppView.alertDetail),
          onAction: (number) {
            _openPhoneDialer(number);
          },
        );
      case AppView.profile:
        return ProfileScreen(
          profile: _profile,
          onSaveProfile: (profile) => setState(() => _profile = profile),
          onBack: () => setState(() => _view = AppView.home),
          onOpenSettings: () => _changeTab(AppTab.settings),
        );
      case AppView.settings:
        return SettingsScreen(
          profile: _profile,
          notifications: _notifications,
          onBack: () => _changeTab(AppTab.home),
          onToggleNotification: (key) => setState(() {
            _notifications[key] = !(_notifications[key] ?? false);
          }),
          onSignOut: _signOut,
          onSaveProfile: (profile) => setState(() => _profile = profile),
        );
    }
  }

  void _changeTab(AppTab tab) {
    setState(() {
      _tab = tab;
      _view = switch (tab) {
        AppTab.home => AppView.home,
        AppTab.alerts => AppView.alerts,
        AppTab.settings => AppView.settings,
      };
    });
  }

  Future<void> _openPhoneDialer([String number = '']) async {
    final sanitizedNumber = number.replaceAll(RegExp(r'[\s()-]'), '');
    final uri = Uri(scheme: 'tel', path: sanitizedNumber);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final password = prefs.getString(_passwordKey);

    if (!mounted) {
      return;
    }

    setState(() {
      if (username != null &&
          username.trim().isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        _credentials = SignupCredentials(
          username: username,
          password: password,
        );
      }
      _isLoadingCredentials = false;
    });
  }

  Future<void> _saveSignupCredentials(SignupCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, credentials.username);
    await prefs.setString(_passwordKey, credentials.password);

    try {
      final auth = AuthService();
      await auth.signUp(
          email: credentials.username, password: credentials.password);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = 'Could not create account: ${e.toString()}';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _credentials = credentials;
      _signupSuccess = 'Account created. Please sign in.';
      _loginError = '';
      _showSignup = false;
    });
  }

  Future<void> _signIn(LoginCredentials input) async {
    try {
      final auth = AuthService();
      final user =
          await auth.signIn(email: input.username, password: input.password);
      if (user == null) throw Exception('No user returned');
      if (!mounted) return;
      setState(() {
        _isAuthenticated = true;
        _loginError = '';
        _signupSuccess = '';
      });
      // reload alerts for the signed-in user
      _loadAlertsFromBackend();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = e.message ?? 'Authentication failed.';
        _signupSuccess = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = 'Authentication failed.';
        _signupSuccess = '';
      });
    }
  }

  void _signOut() {
    final auth = AuthService();
    auth.signOut();
    setState(() {
      _isAuthenticated = false;
      _view = AppView.home;
      _tab = AppTab.home;
    });
  }
}
