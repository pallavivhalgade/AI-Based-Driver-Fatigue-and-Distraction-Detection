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
  runApp(const DriverGuardPolishedApp());
}

class DriverGuardPolishedApp extends StatelessWidget {
  const DriverGuardPolishedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriverGuard AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3EA7FF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF07111F),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF102235),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFF3EA7FF), width: 1.2),
          ),
        ),
      ),
      home: const PolishedSplash(),
    );
  }
}

class PolishedSplash extends StatefulWidget {
  const PolishedSplash({super.key});

  @override
  State<PolishedSplash> createState() => _PolishedSplashState();
}

class _PolishedSplashState extends State<PolishedSplash> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PolishedLogin()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
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
            colors: [Color(0xFF06101D), Color(0xFF0B2942)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFF3EA7FF).withOpacity(.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3EA7FF).withOpacity(.35),
                  ),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 52,
                  color: Color(0xFF55B4FF),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DriverGuard',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'AI DRIVER SAFETY',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.5,
                  color: Color(0xFF82A5C4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PolishedLogin extends StatefulWidget {
  const PolishedLogin({super.key});

  @override
  State<PolishedLogin> createState() => _PolishedLoginState();
}

class _PolishedLoginState extends State<PolishedLogin> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _msg('Enter your credentials');
      return;
    }
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final ok = email.text.trim() == prefs.getString('user_email') &&
        password.text == prefs.getString('user_password');
    if (!mounted) return;
    setState(() => loading = false);
    if (!ok) {
      _msg('Invalid credentials. Register first if needed.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PolishedHome()),
    );
  }

  void _msg(String text) {
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
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3EA7FF).withOpacity(.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 42,
                        color: Color(0xFF55B4FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Sign in to continue monitoring your driving safety.',
                    style: TextStyle(color: Color(0xFF8FA6BA), fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  const _FieldLabel('EMAIL OR USERNAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter email or username',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('PASSWORD'),
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
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Sign in',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PolishedRegister()),
                      ),
                      child: const Text('New to DriverGuard?  Create account'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'AI detection runs locally on the device',
                      style: TextStyle(color: Color(0xFF60778D), fontSize: 12),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          color: Color(0xFF7894AD),
          fontWeight: FontWeight.w700,
        ),
      );
}

class PolishedRegister extends StatefulWidget {
  const PolishedRegister({super.key});

  @override
  State<PolishedRegister> createState() => _PolishedRegisterState();
}

class _PolishedRegisterState extends State<PolishedRegister> {
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
      _msg('Fill all fields');
      return;
    }
    if (password.text.length < 4) {
      _msg('Password must be at least 4 characters');
      return;
    }
    if (password.text != confirm.text) {
      _msg('Passwords do not match');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email.text.trim());
    await prefs.setString('user_password', password.text);
    if (!mounted) return;
    _msg('Account created. Please sign in.');
    Navigator.pop(context);
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(26),
          children: [
            const SizedBox(height: 18),
            const Text(
              'Set up DriverGuard',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your local account to access the safety dashboard.',
              style: TextStyle(color: Color(0xFF8FA6BA)),
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
            const SizedBox(height: 26),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: register,
                child: const Text(
                  'Create account',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolishedHome extends StatefulWidget {
  const PolishedHome({super.key});

  @override
  State<PolishedHome> createState() => _PolishedHomeState();
}

class _PolishedHomeState extends State<PolishedHome> {
  int index = 0;
  final titles = const [
    'Safety dashboard',
    'Emergency contacts',
    'Alert history',
    'Settings',
  ];

  late final List<Widget> pages = [
    const _PageCard(child: legacy.DashboardScreen()),
    const _PageCard(child: legacy.EmergencyContactsScreen()),
    const _PageCard(child: legacy.AlertHistoryScreen()),
    const _PageCard(child: legacy.SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (index == 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF21D47B).withOpacity(.11),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF21D47B)),
                  SizedBox(width: 6),
                  Text(
                    'LOCAL AI',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF21D47B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
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

class _PageCard extends StatelessWidget {
  final Widget child;
  const _PageCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF07111F),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }
}
