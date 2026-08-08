import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
                    const Center(child: Text('Local AI processing • Camera data stays on-device', style: TextStyle(color: Color(0xFF61788D), fontSize: 11))),
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _MonitoringScreen()));
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF12304A), Color(0xFF0B1B2A)]), border: Border.all(color: const Color(0xFF214A68))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1BCB78).withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, size: 7, color: Color(0xFF27D77F)), SizedBox(width: 6), Text('SYSTEM READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF27D77F)))])),
                    const Spacer(),
                    const Text('LOCAL AI', style: TextStyle(fontSize: 10, color: Color(0xFF7F9BB1), fontWeight: FontWeight.w800)),
                  ]),
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
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), sliver: SliverToBoxAdapter(child: Row(children: [Expanded(child: _metric('100%', 'AI readiness', Icons.auto_awesome, const Color(0xFF4EA8FF))), const SizedBox(width: 12), Expanded(child: _metric('ON', 'Offline mode', Icons.wifi_off_rounded, const Color(0xFF27D77F)))]))),
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
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF5AAEFF)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFB9C8D5)))), Text(status, style: const TextStyle(color: Color(0xFF27D77F), fontSize: 11, fontWeight: FontWeight.w700))]));
}

class _MonitoringScreen extends StatefulWidget {
  const _MonitoringScreen();
  @override
  State<_MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<_MonitoringScreen> {
  CameraController? _camera;
  Interpreter? _interpreter;
  final FlutterTts _tts = FlutterTts();
  final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast, enableClassification: true, enableContours: true));
  Timer? _timer;
  bool _cameraOn = false;
  bool _loading = false;
  bool _detecting = false;
  bool _modelLoaded = false;
  bool _emergencyStarted = false;
  int _alerts = 0;
  String _status = 'Ready to monitor';
  String _eyes = 'Open';
  String _yawn = 'No';
  String _head = 'Forward';
  String _driver = 'Safe';
  double _left = 1;
  double _right = 1;
  double _yawnProb = 0;
  double _noYawnProb = 0;
  double _mouth = 0;
  double _headX = 0;
  double _headY = 0;
  DateTime _lastAlert = DateTime.now().subtract(const Duration(seconds: 10));
  static const MethodChannel _sms = MethodChannel('auto_sms_channel');

  @override
  void initState() {
    super.initState();
    _loadModel();
    _tts.setLanguage('en-IN');
    _tts.setSpeechRate(.45);
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/driver_fatigue_model.tflite');
      if (mounted) setState(() => _modelLoaded = true);
    } catch (_) {
      if (mounted) _snack('AI model could not be loaded');
    }
  }

  Future<void> _startCamera() async {
    if (legacy.cameras.isEmpty) return _snack('No camera found');
    if (!_modelLoaded) return _snack('AI model is still loading');
    setState(() => _loading = true);
    try {
      final cam = legacy.cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => legacy.cameras.first);
      _camera = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await _camera!.initialize();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) => _detect());
      if (!mounted) return;
      setState(() { _cameraOn = true; _loading = false; _status = 'Face detection active'; });
      await legacy.LocalStore.addHistory('Camera Started', 'Polished DriverGuard monitoring started');
    } catch (_) {
      if (mounted) setState(() { _loading = false; _cameraOn = false; });
      _snack('Camera could not start');
    }
  }

  Future<void> _stopCamera() async {
    _timer?.cancel();
    _timer = null;
    await _camera?.dispose();
    _camera = null;
    if (!mounted) return;
    setState(() { _cameraOn = false; _detecting = false; _driver = 'Safe'; _status = 'Monitoring stopped'; _alerts = 0; });
    await legacy.LocalStore.addHistory('Camera Stopped', 'DriverGuard monitoring stopped');
  }

  Future<void> _detect() async {
    if (!_cameraOn || _camera == null || _interpreter == null || _detecting || !_camera!.value.isInitialized) return;
    _detecting = true;
    try {
      final file = await _camera!.takePicture();
      final image = InputImage.fromFilePath(file.path);
      final faces = await _faceDetector.processImage(image);
      if (faces.isEmpty) {
        if (mounted) setState(() { _status = 'No face detected'; _driver = 'Attention needed'; });
        _detecting = false;
        return;
      }
      final face = faces.first;
      final bytes = await File(file.path).readAsBytes();
      final scores = _runYawn(bytes, face.boundingBox);
      await _update(face, scores);
    } catch (e) {
      debugPrint('DriverGuard detection: $e');
    }
    _detecting = false;
  }

  List<double> _runYawn(Uint8List bytes, Rect box) {
    final raw = img.decodeImage(bytes);
    if (raw == null) throw Exception('Image decode failed');
    final decoded = img.bakeOrientation(raw);
    var x = box.left.floor();
    var y = box.top.floor();
    var w = box.width.floor();
    var h = box.height.floor();
    final px = (w * .2).floor();
    final py = (h * .25).floor();
    x = (x - px).clamp(0, decoded.width - 1);
    y = (y - py).clamp(0, decoded.height - 1);
    w = (w + px * 2).clamp(1, decoded.width - x);
    h = (h + py * 2).clamp(1, decoded.height - y);
    final crop = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    final resized = img.copyResize(crop, width: 224, height: 224);
    final input = Float32List(224 * 224 * 3);
    var i = 0;
    for (var yy = 0; yy < 224; yy++) {
      for (var xx = 0; xx < 224; xx++) {
        final p = resized.getPixel(xx, yy);
        input[i++] = p.b / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.r / 255.0;
      }
    }
    final output = List.generate(1, (_) => List.filled(4, 0.0));
    _interpreter!.run(input.reshape([1, 224, 224, 3]), output);
    return output[0];
  }

  double _mouthRatio(Face face) {
    final upper = face.contours[FaceContourType.upperLipTop]?.points;
    final lower = face.contours[FaceContourType.lowerLipBottom]?.points;
    if (upper == null || lower == null || upper.isEmpty || lower.isEmpty || face.boundingBox.width <= 0) return 0;
    final uy = upper.map((p) => p.y).reduce((a, b) => a + b) / upper.length;
    final ly = lower.map((p) => p.y).reduce((a, b) => a + b) / lower.length;
    return (ly - uy).abs() / face.boundingBox.width;
  }

  Future<void> _update(Face face, List<double> scores) async {
    final left = face.leftEyeOpenProbability ?? 1;
    final right = face.rightEyeOpenProbability ?? 1;
    final hx = face.headEulerAngleX ?? 0;
    final hy = face.headEulerAngleY ?? 0;
    final mouth = _mouthRatio(face);
    final yp = scores.length > 2 ? scores[2] : 0;
    final np = scores.length > 3 ? scores[3] : 0;
    final yawn = mouth > .075 || (yp > np && yp > .45);
    var eyes = left < .35 && right < .35 ? 'Closed' : 'Open';
    var head = 'Forward';
    var driver = 'Safe';
    var alert = false;
    var message = '';
    if (eyes == 'Closed') { driver = 'Drowsy'; alert = true; message = 'Wake up. Please open your eyes and focus on driving.'; }
    if (yawn) { driver = 'Fatigued'; alert = true; message = 'You are yawning. Please take a break safely.'; }
    if (hy > 18) { head = 'Looking Left'; driver = 'Distracted'; alert = true; message = 'Please look at the road.'; }
    if (hy < -18) { head = 'Looking Right'; driver = 'Distracted'; alert = true; message = 'Please look at the road.'; }
    if (hx.abs() > 12) { head = 'Head Off-Center'; driver = 'Distracted'; alert = true; message = 'Please keep your head straight and look at the road.'; }
    if (alert) {
      _alerts++;
      await _speak(message);
      if (_alerts >= 3 && !_emergencyStarted) await _triggerEmergency();
    } else {
      _alerts = 0;
      _emergencyStarted = false;
    }
    if (!mounted) return;
    setState(() {
      _status = 'Face detected'; _eyes = eyes; _yawn = yawn ? 'Yes' : 'No'; _head = head; _driver = driver;
      _left = left; _right = right; _yawnProb = yp; _noYawnProb = np; _mouth = mouth; _headX = hx; _headY = hy;
    });
  }

  Future<void> _speak(String message) async {
    final now = DateTime.now();
    if (now.difference(_lastAlert).inSeconds < 2) return;
    _lastAlert = now;
    await _tts.stop();
    await _tts.speak(message);
    await legacy.LocalStore.addHistory('Driver Alert', message);
  }

  Future<void> _triggerEmergency() async {
    _emergencyStarted = true;
    final prefs = await SharedPreferences.getInstance();
    final contacts = prefs.getStringList('emergency_contacts') ?? [];
    final message = 'Emergency Alert: Driver fatigue detected. The driver ignored 3 alerts. Please contact the driver immediately.';
    await _sendTelegram(message);
    final permission = await Permission.sms.request();
    for (final contact in contacts) {
      final parts = contact.split('|');
      final phone = parts.length > 1 ? parts[1].trim() : contact.trim();
      if (phone.isEmpty) continue;
      var sent = false;
      if (permission.isGranted) {
        try { sent = await _sms.invokeMethod('sendSms', {'phone': phone, 'message': message}) == true; } catch (_) {}
      }
      if (!sent) {
        try { final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}'); if (await canLaunchUrl(uri)) { await launchUrl(uri); } } catch (_) {}
      }
    }
    await legacy.LocalStore.addHistory('Emergency Alert', 'Three fatigue/distraction alerts triggered emergency workflow');
  }

  Future<void> _sendTelegram(String message) async {
    const token = '8328978924:AAF2amSV-pY7CNuuVbS1HhASzWmQ8JPZjj4';
    const chat = '5580786238';
    try {
      await http.post(Uri.parse('https://api.telegram.org/bot$token/sendMessage'), body: {'chat_id': chat, 'text': message}).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _camera?.dispose();
    _interpreter?.close();
    _faceDetector.close();
    _tts.stop();
    super.dispose();
  }

  Color _driverColor() => _driver == 'Safe' ? const Color(0xFF27D77F) : _driver == 'Drowsy' || _driver == 'Fatigued' ? const Color(0xFFFFB74D) : const Color(0xFFFF5F67);
  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final c = _driverColor();
    return Scaffold(
      backgroundColor: const Color(0xFF07111D),
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DriverGuard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text('LIVE SAFETY MONITOR', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: Color(0xFF7892A8), fontWeight: FontWeight.w700))]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text(_cameraOn ? '● LIVE' : '○ OFF', style: TextStyle(color: _cameraOn ? const Color(0xFF27D77F) : const Color(0xFF8BA0B2), fontWeight: FontWeight.w800, fontSize: 11))))],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
        Container(
          height: 330,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(28), border: Border.all(color: _cameraOn ? const Color(0xFF2C9BFF).withOpacity(.65) : const Color(0xFF193148))),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            if (_cameraOn && _camera != null) Positioned.fill(child: CameraPreview(_camera!)) else Center(child: _loading ? const CircularProgressIndicator() : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.videocam_off_outlined, size: 58, color: Color(0xFF456177)), SizedBox(height: 12), Text('Camera ready', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Start monitoring to activate AI', style: TextStyle(color: Color(0xFF7892A8), fontSize: 12))])),
            Positioned(top: 14, left: 14, child: _chip(_cameraOn ? 'AI MONITORING ACTIVE' : 'STANDBY', _cameraOn ? const Color(0xFF27D77F) : const Color(0xFF7892A8))),
            if (_cameraOn) Center(child: Container(width: 190, height: 235, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4EA8FF), width: 2), borderRadius: BorderRadius.circular(20)))),
            if (_cameraOn) Positioned(bottom: 14, left: 14, child: Text('Eyes  $_eyes\nYawn  $_yawn\nHead  $_head', style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(24), border: Border.all(color: c.withOpacity(.35))), child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: c.withOpacity(.1), shape: BoxShape.circle), child: Icon(_driver == 'Safe' ? Icons.shield_rounded : Icons.warning_rounded, color: c, size: 29)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SAFETY STATUS', style: TextStyle(color: Color(0xFF7892A8), fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(_driver.toUpperCase(), style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(_status, style: const TextStyle(color: Color(0xFF9BB0C1), fontSize: 12))]))])),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _readout('EYES', _eyes, Icons.visibility_outlined, _eyes == 'Closed' ? const Color(0xFFFF5F67) : const Color(0xFF27D77F))), const SizedBox(width: 10), Expanded(child: _readout('YAWN', _yawn, Icons.face_retouching_natural_outlined, _yawn == 'Yes' ? const Color(0xFFFFB74D) : const Color(0xFF27D77F))), const SizedBox(width: 10), Expanded(child: _readout('HEAD', _head, Icons.person_outline, _head == 'Forward' ? const Color(0xFF27D77F) : const Color(0xFFFFB74D)))]),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AI SIGNALS', style: TextStyle(color: Color(0xFF7892A8), fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800)), const SizedBox(height: 14), _signal('Left eye open probability', '${(_left * 100).toStringAsFixed(0)}%'), _signal('Right eye open probability', '${(_right * 100).toStringAsFixed(0)}%'), _signal('Yawn probability', '${(_yawnProb * 100).toStringAsFixed(0)}%'), _signal('Mouth opening ratio', _mouth.toStringAsFixed(3)), _signal('Head X / Y', '${_headX.toStringAsFixed(1)}° / ${_headY.toStringAsFixed(1)}°')])) ,
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _counterCard('ALERTS', '$_alerts / 3', Icons.notifications_active_outlined, _alerts > 0 ? const Color(0xFFFFB74D) : const Color(0xFF27D77F))), const SizedBox(width: 10), Expanded(child: _counterCard('AI MODEL', _modelLoaded ? 'READY' : 'LOADING', Icons.memory_outlined, _modelLoaded ? const Color(0xFF27D77F) : const Color(0xFFFFB74D)))]),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: SizedBox(height: 54, child: FilledButton.icon(onPressed: _cameraOn ? null : _startCamera, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start monitoring', style: TextStyle(fontWeight: FontWeight.w800))))), const SizedBox(width: 10), Expanded(child: SizedBox(height: 54, child: OutlinedButton.icon(onPressed: _cameraOn ? _stopCamera : null, icon: const Icon(Icons.stop_rounded), label: const Text('Stop', style: TextStyle(fontWeight: FontWeight.w800)))))]),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Back to safety dashboard')),
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.7), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.circle, size: 7, color: color), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))]));
  Widget _readout(String title, String value, IconData icon, Color color) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF172F44))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 19), const SizedBox(height: 9), Text(title, style: const TextStyle(color: Color(0xFF7892A8), fontSize: 9, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12))]));
  Widget _signal(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF9BB0C1), fontSize: 12))), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]));
  Widget _counterCard(String title, String value, IconData icon, Color color) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(19), border: Border.all(color: color.withOpacity(.2))), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF7892A8), fontSize: 9, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900))]))]));
}
