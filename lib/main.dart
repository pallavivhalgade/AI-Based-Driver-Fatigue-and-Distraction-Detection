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
    const green = Color(0xFF48E08B);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriverGuard AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07111B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF07111B),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF0C1B2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF173043)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF173043)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: green),
          ),
        ),
      ),
      home: const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06101A), Color(0xFF0A2332)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _BrandMark(size: 88),
              SizedBox(height: 24),
              Text(
                'DriverGuard',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 5),
              Text(
                'AI DRIVER SAFETY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.4,
                  color: Color(0xFF7D98AA),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 34),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF48E08B).withOpacity(.10),
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(color: const Color(0xFF48E08B).withOpacity(.35)),
      ),
      child: const Icon(
        Icons.shield_rounded,
        color: Color(0xFF48E08B),
        size: 48,
      ),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');

    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Enter your credentials.');
      return;
    }

    if (savedEmail == null || savedPassword == null) {
      _message('No account found. Please create an account first.');
      return;
    }

    if (email.text.trim() != savedEmail || password.text != savedPassword) {
      _message('Invalid email/username or password.');
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const _HomeShell()),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: _BrandMark(size: 76)),
                  const SizedBox(height: 28),
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Sign in to continue with DriverGuard AI.',
                    style: TextStyle(color: Color(0xFF8BA2B2), fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  const _Label('EMAIL OR USERNAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter email or username',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _Label('PASSWORD'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: password,
                    obscureText: hidden,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => hidden = !hidden),
                        icon: Icon(
                          hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: login,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF48E08B),
                        foregroundColor: const Color(0xFF06130E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const _RegisterScreen()),
                      ),
                      child: const Text('New to DriverGuard?  Create account'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Existing AI models and monitoring logic are preserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF5F7687), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 1.2,
        color: Color(0xFF7893A5),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _RegisterScreen extends StatefulWidget {
  const _RegisterScreen();

  @override
  State<_RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<_RegisterScreen> {
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

  Future<void> register() async {
    if (email.text.trim().isEmpty || password.text.isEmpty || confirm.text.isEmpty) {
      _message('Fill all fields.');
      return;
    }
    if (password.text.length < 4) {
      _message('Password must be at least 4 characters.');
      return;
    }
    if (password.text != confirm.text) {
      _message('Passwords do not match.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email.text.trim());
    await prefs.setString('user_password', password.text);

    if (!mounted) return;
    _message('Account created. Please sign in.');
    Navigator.pop(context);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(26),
        children: [
          const _BrandMark(size: 72),
          const SizedBox(height: 24),
          const Text(
            'Set up DriverGuard',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your local account for the safety dashboard.',
            style: TextStyle(color: Color(0xFF8BA2B2)),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: email,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Email or username',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              hintText: 'Password',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.verified_user_outlined),
              hintText: 'Confirm password',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: register,
              child: const Text(
                'Create account',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int index = 0;

  void openMonitoring() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const legacy.DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(onStart: openMonitoring),
      const legacy.EmergencyContactsScreen(),
      const legacy.AlertHistoryScreen(),
      const legacy.SettingsScreen(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Safety',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final VoidCallback onStart;
  const _DashboardHome({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DriverGuard AI',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 2),
            Text(
              'DRIVER SAFETY SYSTEM',
              style: TextStyle(
                fontSize: 8,
                color: Color(0xFF718A9B),
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: _StatusPill(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _HeroCard(onStart: onStart),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: const [
                Expanded(child: _MetricCard(icon: Icons.visibility_outlined, value: 'READY', label: 'Eye detection')),
                SizedBox(width: 10),
                Expanded(child: _MetricCard(icon: Icons.face_retouching_natural_outlined, value: 'READY', label: 'Yawn detection')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: const [
                Expanded(child: _MetricCard(icon: Icons.screen_rotation_alt_outlined, value: 'READY', label: 'Head pose')),
                SizedBox(width: 10),
                Expanded(child: _MetricCard(icon: Icons.volume_up_outlined, value: 'ON', label: 'Voice alerts')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1B2A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF173043)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protection overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 15),
                  _ProtectionRow(Icons.visibility_outlined, 'Eye & fatigue detection', 'Ready'),
                  _ProtectionRow(Icons.face_retouching_natural_outlined, 'Yawn detection', 'Ready'),
                  _ProtectionRow(Icons.screen_rotation_alt_outlined, 'Head-pose monitoring', 'Ready'),
                  _ProtectionRow(Icons.notifications_active_outlined, 'Voice + emergency alerts', 'Enabled'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF48E08B).withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF48E08B).withOpacity(.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, size: 7, color: Color(0xFF48E08B)),
          SizedBox(width: 6),
          Text(
            'SYSTEM READY',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF48E08B),
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onStart;
  const _HeroCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1A27),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF1A3447)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF48E08B).withOpacity(.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF48E08B)),
                    SizedBox(width: 6),
                    Text(
                      'ON-DEVICE AI',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFF48E08B),
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.shield_outlined, color: Color(0xFF3E5E70)),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Your safety,\nmonitored in real time.',
            style: TextStyle(
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Detect eye closure, yawning and head-position changes while you drive.',
            style: TextStyle(
              color: Color(0xFF8FA6B5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF48E08B),
                foregroundColor: const Color(0xFF06130E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 23),
              label: const Text(
                'Start safety monitoring',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Camera + ML inference starts only after you tap Start',
              style: TextStyle(color: Color(0xFF607889), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1A27),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF173043)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: const Color(0xFF48E08B)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF48E08B),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF7890A0)),
          ),
        ],
      ),
    );
  }
}

class _ProtectionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;

  const _ProtectionRow(this.icon, this.title, this.status);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF48E08B).withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF82A0AF)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF48E08B),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
