import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_core.dart' as legacy;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    legacy.cameras = await availableCameras();
  } catch (_) {
    legacy.cameras = [];
  }
  runApp(const DriverGuardApp());
}

class DriverGuardApp extends StatelessWidget {
  const DriverGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4EA8FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriverGuard AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111D),
        colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      ),
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const _Login()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Logo(size: 84),
              SizedBox(height: 22),
              Text('DriverGuard', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('AI-POWERED DRIVER SAFETY', style: TextStyle(letterSpacing: 2.2, color: Color(0xFF7E9BB7), fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class _Logo extends StatelessWidget {
  final double size;
  const _Logo({required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4EA8FF).withOpacity(.12),
          border: Border.all(color: const Color(0xFF4EA8FF).withOpacity(.35)),
          boxShadow: [BoxShadow(color: const Color(0xFF4EA8FF).withOpacity(.12), blurRadius: 28)],
        ),
        child: const Icon(Icons.shield_rounded, color: Color(0xFF5DB0FF), size: 48),
      );
}

class _Login extends StatefulWidget {
  const _Login();
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Enter your credentials');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (email.text.trim() == prefs.getString('user_email') && password.text == prefs.getString('user_password')) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const _Home()));
    } else {
      _message('Invalid credentials. Register first if needed.');
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: _Logo(size: 76)),
                    const SizedBox(height: 28),
                    const Text('Welcome back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    const Text('Your drive. Your safety. Protected by AI.', style: TextStyle(color: Color(0xFF91A7BA), fontSize: 15)),
                    const SizedBox(height: 30),
                    _label('EMAIL OR USERNAME'),
                    const SizedBox(height: 8),
                    _input(email, 'Enter email or username', Icons.person_outline),
                    const SizedBox(height: 17),
                    _label('PASSWORD'),
                    const SizedBox(height: 8),
                    _input(password, 'Enter password', Icons.lock_outline, obscure: obscure, suffix: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: _login, child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                    const SizedBox(height: 12),
                    Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _Register())), child: const Text('New to DriverGuard?  Create account'))),
                    const SizedBox(height: 20),
                    const Center(child: Text('Local AI processing • Your camera data stays on-device', style: TextStyle(color: Color(0xFF61788D), fontSize: 11))),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _Register extends StatefulWidget {
  const _Register();
  @override
  State<_Register> createState() => _RegisterState();
}

class _RegisterState extends State<_Register> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (email.text.trim().isEmpty || password.text.isEmpty || confirm.text.isEmpty) {
      _message('Fill all fields');
      return;
    }
    if (password.text.length < 4 || password.text != confirm.text) {
      _message(password.text.length < 4 ? 'Password must be at least 4 characters' : 'Passwords do not match');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email.text.trim());
    await prefs.setString('user_password', password.text);
    if (!mounted) return;
    _message('Account created. Please sign in.');
    Navigator.pop(context);
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account', style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
          padding: const EdgeInsets.all(26),
          children: [
            const SizedBox(height: 18),
            const Text('Set up DriverGuard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Create your local safety profile.', style: TextStyle(color: Color(0xFF91A7BA))),
            const SizedBox(height: 26),
            _input(email, 'Email or username', Icons.person_outline),
            const SizedBox(height: 15),
            _input(password, 'Password', Icons.lock_outline, obscure: true),
            const SizedBox(height: 15),
            _input(confirm, 'Confirm password', Icons.verified_user_outlined, obscure: true),
            const SizedBox(height: 24),
            SizedBox(height: 56, child: FilledButton(onPressed: _register, child: const Text('Create account', style: TextStyle(fontWeight: FontWeight.w800)))),
          ],
        ),
      );
}

Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 10, letterSpacing: 1.25, color: Color(0xFF7691A8), fontWeight: FontWeight.w800));

Widget _input(TextEditingController controller, String hint, IconData icon, {bool obscure = false, Widget? suffix}) => TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF0D1D2D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );

class _Home extends StatefulWidget {
  const _Home();
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _SafetyHome(),
      const legacy.EmergencyContactsScreen(),
      const legacy.AlertHistoryScreen(),
      const legacy.SettingsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _SafetyHome extends StatelessWidget {
  const _SafetyHome();

  void _start(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const legacy.DashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good to see you', style: TextStyle(color: Color(0xFF8DA4B8), fontSize: 13)), SizedBox(height: 4), Text('Ready for a safe drive?', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800))])),
                Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF102235), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shield_outlined, color: Color(0xFF59AEFF))),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF12304A), Color(0xFF0B1B2A)]),
                border: Border.all(color: Color(0xFF214A68)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1BCB78).withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, size: 7, color: Color(0xFF27D77F)), SizedBox(width: 6), Text('SYSTEM READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF27D77F))])), const Spacer(), const Text('LOCAL AI', style: TextStyle(fontSize: 10, color: Color(0xFF7F9BB1), fontWeight: FontWeight.w800))]),
                const SizedBox(height: 24),
                const Text('Drive with confidence.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Monitor fatigue, yawning and driver attention in real time.', style: TextStyle(color: Color(0xFF9BB0C1), height: 1.45)),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(onPressed: () => _start(context), icon: const Icon(Icons.videocam_outlined), label: const Text('Start Monitoring', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(child: Row(children: [Expanded(child: _metric('100%', 'AI readiness', Icons.auto_awesome, const Color(0xFF4EA8FF))), const SizedBox(width: 12), Expanded(child: _metric('ON', 'Offline mode', Icons.wifi_off_rounded, const Color(0xFF27D77F)))])),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF172F44))),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Protection overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 15),
                _ProtectionRow(Icons.visibility_outlined, 'Eye & fatigue detection', 'Ready'),
                _ProtectionRow(Icons.face_retouching_natural_outlined, 'Yawn detection', 'Ready'),
                _ProtectionRow(Icons.screen_lock_portrait_outlined, 'Attention monitoring', 'Ready'),
                _ProtectionRow(Icons.notifications_active_outlined, 'Voice alerts', 'Enabled'),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _metric(String value, String label, IconData icon, Color color) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF172F44))),
      child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Color(0xFF7F96AA), fontSize: 11))]))]),
    );

class _ProtectionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  const _ProtectionRow(this.icon, this.title, this.status);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF5AAEFF)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFB9C8D5)))), const Text('Ready', style: TextStyle(color: Color(0xFF27D77F), fontSize: 11, fontWeight: FontWeight.w700))]));
}
