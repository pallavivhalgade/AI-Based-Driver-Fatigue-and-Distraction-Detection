import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'driver_core.dart';

void main() => runApp(const DriverGuardApp());

class DriverGuardApp extends StatelessWidget {
  const DriverGuardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DriverGuard AI',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF06111D),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27D77F), brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const _PolishedSplash(),
      );
}

class _PolishedSplash extends StatefulWidget {
  const _PolishedSplash();
  @override
  State<_PolishedSplash> createState() => _PolishedSplashState();
}

class _PolishedSplashState extends State<_PolishedSplash> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const _HomeScreen()));
    });
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shield_outlined, size: 72, color: Color(0xFF27D77F)),
          SizedBox(height: 18),
          Text('DRIVERGUARD AI', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
          SizedBox(height: 8),
          Text('Intelligent driver safety monitoring', style: TextStyle(color: Color(0xFF8AA0B3))),
        ]),),
      );
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();
  void _start(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _MonitoringScreen()));
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF06111D),
        body: SafeArea(
          child: CustomScrollView(slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: Row(children: [
                CircleAvatar(radius: 22, backgroundColor: Color(0xFF0E2739), child: Icon(Icons.shield_outlined, color: Color(0xFF27D77F))),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DriverGuard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 2), Text('AI SAFETY SYSTEM', style: TextStyle(fontSize: 10, color: Color(0xFF7F9BB1), fontWeight: FontWeight.w800, letterSpacing: 1.1))])),
                Icon(Icons.notifications_none_rounded, color: Color(0xFF9BB0C1)),
              ])),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF12304A), Color(0xFF0B1B2A)]), border: Border.all(color: Color(0xFF214A68))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1BCB78).withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, size: 7, color: Color(0xFF27D77F)), SizedBox(width: 6), Text('SYSTEM READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF27D77F)))])), const Spacer(), const Text('LOCAL AI', style: TextStyle(fontSize: 10, color: Color(0xFF7F9BB1), fontWeight: FontWeight.w800))]),
                  const SizedBox(height: 24),
                  const Text('Drive with confidence.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Monitor fatigue, yawning and driver attention in real time.', style: TextStyle(color: Color(0xFF9BB0C1), height: 1.45)),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(onPressed: () => _start(context), icon: const Icon(Icons.videocam_outlined), label: const Text('Start Monitoring', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                ]),
              )),
            ),
            SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), sliver: SliverToBoxAdapter(child: Row(children: [Expanded(child: _metric('100%', 'AI readiness', Icons.auto_awesome, const Color(0xFF4EA8FF))), const SizedBox(width: 12), Expanded(child: _metric('ON', 'Offline mode', Icons.wifi_off_rounded, const Color(0xFF27D77F)))]))),
            SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), sliver: SliverToBoxAdapter(child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF172F44))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Protection overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(height: 15), _ProtectionRow(Icons.visibility_outlined, 'Eye & fatigue detection', 'Ready'), _ProtectionRow(Icons.face_retouching_natural_outlined, 'Yawn detection', 'Ready'), _ProtectionRow(Icons.screen_lock_portrait_outlined, 'Attention monitoring', 'Ready'), _ProtectionRow(Icons.notifications_active_outlined, 'Voice alerts', 'Enabled')]))),),
          ]),
        ),
      );
}

Widget _metric(String value, String label, IconData icon, Color color) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0C1B2A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF172F44))), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Color(0xFF7F96AA), fontSize: 11))]))]));

class _ProtectionRow extends StatelessWidget { final IconData icon; final String title; final String status; const _ProtectionRow(this.icon, this.title, this.status); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [Icon(icon, size: 20, color: const Color(0xFF5AAEFF)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFB9C8D5)))), Text(status, style: const TextStyle(color: Color(0xFF27D77F), fontSize: 11, fontWeight: FontWeight.w700))])); }

class _MonitoringScreen extends StatefulWidget { const _MonitoringScreen(); @override State<_MonitoringScreen> createState() => _MonitoringScreenState(); }

class _MonitoringScreenState extends State<_MonitoringScreen> {
  CameraController? _camera;
  FaceDetector? _detector;
  final FlutterTts _tts = FlutterTts();
  Timer? _timer;
  bool _running = false;
  bool _processing = false;
  String _status = 'Camera ready';
  String _eyes = 'Open', _yawn = 'No', _head = 'Forward', _driver = 'Safe';
  double _left = 1, _right = 1, _yawnProb = 0, _noYawnProb = 0, _mouth = 0, _headX = 0, _headY = 0;
  int _alerts = 0;
  DateTime _lastAlert = DateTime.fromMillisecondsSinceEpoch(0);
  bool _emergencyStarted = false;

  @override void initState() { super.initState(); _detector = FaceDetector(options: FaceDetectorOptions(enableClassification: true, enableContours: true, enableTracking: true)); }
  @override void dispose() { _timer?.cancel(); _camera?.dispose(); _detector?.close(); _tts.stop(); super.dispose(); }

  Future<void> _start() async {
    if (_running) return;
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      final controller = CameraController(front, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await controller.initialize();
      if (!mounted) { await controller.dispose(); return; }
      setState(() { _camera = controller; _running = true; _status = 'Monitoring active'; });
      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _captureAndAnalyze());
    } catch (e) { if (mounted) setState(() => _status = 'Camera unavailable'); }
  }

  Future<void> _stop() async { _timer?.cancel(); _timer = null; final c = _camera; _camera = null; if (mounted) setState(() { _running = false; _status = 'Monitoring stopped'; }); await c?.dispose(); }

  Future<void> _captureAndAnalyze() async { if (!_running || _processing || _camera == null || !_camera!.value.isInitialized) return; _processing = true; try { final image = await _camera!.takePicture(); final input = InputImage.fromFilePath(image.path); final faces = await _detector!.processImage(input); if (faces.isNotEmpty) await _update(faces.first, const [0, 0, 0, 1]); } catch (_) {} finally { _processing = false; } }

  double _mouthRatio(Face face) { final upper = face.contours[FaceContourType.upperLipTop]?.points; final lower = face.contours[FaceContourType.lowerLipBottom]?.points; if (upper == null || lower == null || upper.isEmpty || lower.isEmpty || face.boundingBox.width <= 0) return 0; final uy = upper.map((p) => p.y).reduce((a, b) => a + b) / upper.length; final ly = lower.map((p) => p.y).reduce((a, b) => a + b) / lower.length; return (ly - uy).abs() / face.boundingBox.width; }

  Future<void> _update(Face face, List<double> scores) async {
    final double left = (face.leftEyeOpenProbability ?? 1).toDouble();
    final double right = (face.rightEyeOpenProbability ?? 1).toDouble();
    final double hx = (face.headEulerAngleX ?? 0).toDouble();
    final double hy = (face.headEulerAngleY ?? 0).toDouble();
    final double mouth = _mouthRatio(face);
    final double yp = (scores.length > 2 ? scores[2] : 0).toDouble();
    final double np = (scores.length > 3 ? scores[3] : 0).toDouble();
    final yawn = mouth > .075 || (yp > np && yp > .45);
    final eyes = left < .35 && right < .35 ? 'Closed' : 'Open';
    var head = 'Forward'; var driver = 'Safe'; var alert = false; var message = '';
    if (eyes == 'Closed') { driver = 'Drowsy'; alert = true; message = 'Wake up. Please open your eyes and focus on driving.'; }
    if (yawn) { driver = 'Fatigued'; alert = true; message = 'You are yawning. Please take a break safely.'; }
    if (hy > 18) { head = 'Looking Left'; driver = 'Distracted'; alert = true; message = 'Please look at the road.'; }
    if (hy < -18) { head = 'Looking Right'; driver = 'Distracted'; alert = true; message = 'Please look at the road.'; }
    if (hx.abs() > 12) { head = 'Head Off-Center'; driver = 'Distracted'; alert = true; message = 'Please keep your head straight and look at the road.'; }
    if (alert) { _alerts++; await _speak(message); } else { _alerts = 0; _emergencyStarted = false; }
    if (!mounted) return;
    setState(() { _status = 'Face detected'; _eyes = eyes; _yawn = yawn ? 'Yes' : 'No'; _head = head; _driver = driver; _left = left; _right = right; _yawnProb = yp; _noYawnProb = np; _mouth = mouth; _headX = hx; _headY = hy; });
  }

  Future<void> _speak(String message) async { final now = DateTime.now(); if (now.difference(_lastAlert).inSeconds < 2) return; _lastAlert = now; await _tts.stop(); await _tts.speak(message); }

  Color get _driverColor => _driver == 'Safe' ? const Color(0xFF27D77F) : const Color(0xFFFFB84D);
  Widget _signal(String title, String value, IconData icon, Color color) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF0B1B2A), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF18364D))), child: Row(children: [Icon(icon, color: color, size: 22), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFAEC0CE)))), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800))]));
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF06111D), appBar: AppBar(backgroundColor: const Color(0xFF06111D), title: const Text('Live Monitoring', style: TextStyle(fontWeight: FontWeight.w800)), actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text(_running ? '● LIVE' : '○ IDLE', style: TextStyle(color: _running ? const Color(0xFF27D77F) : const Color(0xFF8AA0B3), fontSize: 12, fontWeight: FontWeight.w800))))]), body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), children: [Container(height: 300, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF0B1B2A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF1A3A52))), child: _camera != null && _camera!.value.isInitialized ? CameraPreview(_camera!) : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.videocam_off_outlined, size: 48, color: Color(0xFF557083)), SizedBox(height: 10), Text('Camera is ready', style: TextStyle(color: Color(0xFF8EA5B7)))]))), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _driverColor.withOpacity(.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: _driverColor.withOpacity(.35))), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: _driverColor.withOpacity(.12), shape: BoxShape.circle), child: Icon(_driver == 'Safe' ? Icons.verified_user_outlined : Icons.warning_amber_rounded, color: _driverColor)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SAFETY STATUS', style: TextStyle(fontSize: 10, color: Color(0xFF7F96AA), fontWeight: FontWeight.w800, letterSpacing: 1)), const SizedBox(height: 5), Text(_driver.toUpperCase(), style: TextStyle(fontSize: 24, color: _driverColor, fontWeight: FontWeight.w900))])), Text('$_alerts', style: TextStyle(fontSize: 28, color: _driverColor, fontWeight: FontWeight.w900))])), const SizedBox(height: 14), _signal('Eye state', _eyes, Icons.visibility_outlined, _eyes == 'Open' ? const Color(0xFF27D77F) : const Color(0xFFFFB84D)), const SizedBox(height: 10), _signal('Yawning', _yawn, Icons.face_retouching_natural_outlined, _yawn == 'No' ? const Color(0xFF27D77F) : const Color(0xFFFFB84D)), const SizedBox(height: 10), _signal('Head position', _head, Icons.person_pin_circle_outlined, _head == 'Forward' ? const Color(0xFF27D77F) : const Color(0xFFFFB84D)), const SizedBox(height: 16), Row(children: [Expanded(child: FilledButton.icon(onPressed: _running ? null : _start, icon: const Icon(Icons.play_arrow_rounded), label: const Text('START'))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: _running ? _stop : null, icon: const Icon(Icons.stop_rounded), label: const Text('STOP')))]), const SizedBox(height: 12), Text('Eye confidence: ${(_left * 100).toStringAsFixed(0)}% / ${(_right * 100).toStringAsFixed(0)}%   •   Yawn: ${(_yawnProb * 100).toStringAsFixed(0)}%   •   Head X ${_headX.toStringAsFixed(1)}°  Y ${_headY.toStringAsFixed(1)}°', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF71899B), fontSize: 11))]));
}
