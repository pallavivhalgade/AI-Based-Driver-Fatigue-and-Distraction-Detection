import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (_) {
    cameras = [];
  }
  runApp(const DriverMonitorApp());
}

class DriverMonitorApp extends StatelessWidget {
  const DriverMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Driver Fatigue Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: AppColors.bg),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const bg = Color(0xFF020B17);
  static const card = Color(0xFF081827);
  static const blue = Color(0xFF1998FF);
  static const green = Color(0xFF20E35A);
  static const red = Color(0xFFFF3B3B);
  static const yellow = Color(0xFFFFC107);
  static const textGrey = Color(0xFFB8C2CC);
}

class LocalStore {
  static Future<void> addHistory(String title, String details) async {
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getStringList('alert_history') ?? [];
    final now = DateTime.now();
    final stamp =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    old.insert(0, '$title|$details|$stamp');
    await prefs.setStringList('alert_history', old.take(100).toList());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.airline_seat_recline_extra, size: 110, color: AppColors.blue),
              SizedBox(height: 24),
              Text('AI DRIVER', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              Text('FATIGUE DETECTION', textAlign: TextAlign.center, style: TextStyle(color: AppColors.blue, fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 18),
              Text('Offline hybrid monitoring', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
              SizedBox(height: 30),
              CircularProgressIndicator(color: AppColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      showMessage('Enter email/username and password');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');
    if (savedEmail == null || savedPassword == null) {
      showMessage('No account found. Please register first.');
      return;
    }
    if (email == savedEmail && password == savedPassword) {
      await LocalStore.addHistory('Login', 'User logged in successfully');
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
    } else {
      showMessage('Invalid email/username or password');
    }
  }

  void showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget inputBox(String hint, IconData icon, TextEditingController controller, {bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Icon(icon, color: AppColors.blue),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 35),
            const Icon(Icons.airline_seat_recline_extra, size: 110, color: AppColors.blue),
            const SizedBox(height: 18),
            const Text('AI DRIVER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold)),
            const Text('FATIGUE DETECTION', textAlign: TextAlign.center, style: TextStyle(color: AppColors.blue, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 42),
            inputBox('Email or Username', Icons.person_outline, emailController),
            const SizedBox(height: 18),
            inputBox(
              'Password',
              Icons.lock_outline,
              passwordController,
              obscure: hidePassword,
              suffix: IconButton(
                icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                icon: const Icon(Icons.login),
                label: const Text('LOGIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onPressed: loginUser,
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('New user? Register here', style: TextStyle(color: AppColors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showMessage('Fill all fields');
      return;
    }
    if (password.length < 4) {
      showMessage('Password must be at least 4 characters');
      return;
    }
    if (password != confirm) {
      showMessage('Passwords do not match');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await LocalStore.addHistory('Registration', 'New user account created');
    showMessage('Registration successful. Please login.');
    if (!mounted) return;
    Navigator.pop(context);
  }

  void showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget inputBox(String hint, IconData icon, TextEditingController controller, {bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Icon(icon, color: AppColors.blue),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, iconTheme: const IconThemeData(color: Colors.white), title: const Text('Register', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Icon(Icons.person_add_alt_1, color: AppColors.blue, size: 90),
          const SizedBox(height: 25),
          inputBox('Email or Username', Icons.person, emailController),
          const SizedBox(height: 18),
          inputBox('Password', Icons.lock, passwordController, obscure: hidePassword, suffix: IconButton(icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: () => setState(() => hidePassword = !hidePassword))),
          const SizedBox(height: 18),
          inputBox('Confirm Password', Icons.lock_outline, confirmPasswordController, obscure: hideConfirmPassword, suffix: IconButton(icon: Icon(hideConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword))),
          const SizedBox(height: 30),
          SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              icon: const Icon(Icons.app_registration),
              label: const Text('REGISTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: registerUser,
            ),
          ),
        ],
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  final screens = const [DashboardScreen(), EmergencyContactsScreen(), AlertHistoryScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF020812),
        selectedItemColor: AppColors.blue,
        unselectedItemColor: Colors.white54,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CameraController? cameraController;
  Interpreter? interpreter;
  final FlutterTts flutterTts = FlutterTts();
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      enableLandmarks: false,
      enableContours: true,
    ),
  );

  Timer? detectionTimer;
  bool isCameraOn = false;
  bool isCameraLoading = false;
  bool isModelLoaded = false;
  bool isDetecting = false;
  bool emergencyHistoryAdded = false;

  String modelStatus = 'Loading model...';
  String detectionStatus = 'Waiting';
  String yawnModelResult = 'Unknown';
  String eyes = 'Unknown';
  String yawning = 'Unknown';
  String headPose = 'Unknown';
  String driverStatus = 'Idle';
  int alertCount = 0;
  double yawnConfidence = 0.0;
  double leftEyeProb = 1.0;
  double rightEyeProb = 1.0;
  double yawnProb = 0.0;
  double noYawnProb = 0.0;
  double mouthOpenRatio = 0.0;
  double headXValue = 0.0;
  double headYValue = 0.0;

  final List<String> labels = ['Closed', 'Open', 'Yawn', 'NoYawn'];
  DateTime lastVoiceAlert = DateTime.now().subtract(const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    loadModel();
    setupTts();
  }

  Future<void> setupTts() async {
    await flutterTts.setLanguage('en-IN');
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setVolume(1.0);
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/driver_fatigue_model.tflite');
      if (!mounted) return;
      setState(() {
        isModelLoaded = true;
        modelStatus = 'TFLite yawn model loaded';
      });
      await LocalStore.addHistory('Model Loaded', 'TFLite model loaded for yawn detection');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isModelLoaded = false;
        modelStatus = 'Model load failed';
      });
      showMessage('TFLite model failed to load. Check asset path.');
    }
  }

  @override
  void dispose() {
    detectionTimer?.cancel();
    cameraController?.dispose();
    interpreter?.close();
    faceDetector.close();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> turnOnCamera() async {
    if (cameras.isEmpty) {
      showMessage('No camera found');
      return;
    }
    if (!isModelLoaded) {
      showMessage('Model is not loaded yet');
      return;
    }
    setState(() => isCameraLoading = true);

    try {
      final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await cameraController!.initialize();

      detectionTimer?.cancel();
      detectionTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) => runHybridDetection());

      await LocalStore.addHistory('Camera Started', 'Offline hybrid monitoring started');
      if (!mounted) return;
      setState(() {
        isCameraOn = true;
        isCameraLoading = false;
        driverStatus = 'Monitoring';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isCameraOn = false;
        isCameraLoading = false;
      });
      showMessage('Camera could not start');
    }
  }

  Future<void> turnOffCamera() async {
    detectionTimer?.cancel();
    detectionTimer = null;
    await cameraController?.dispose();
    cameraController = null;
    await LocalStore.addHistory('Camera Stopped', 'Offline hybrid monitoring stopped');
    if (!mounted) return;
    setState(() {
      isCameraOn = false;
      isCameraLoading = false;
      isDetecting = false;
      driverStatus = 'Idle';
    });
  }

  Future<void> runHybridDetection() async {
    if (!isCameraOn || cameraController == null || interpreter == null || isDetecting) return;
    if (!cameraController!.value.isInitialized) return;
    isDetecting = true;

    try {
      final file = await cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            detectionStatus = 'No face detected';
            driverStatus = 'No Face';
          });
        }
        isDetecting = false;
        return;
      }

      final face = faces.first;
      final bytes = await File(file.path).readAsBytes();
      final yawnScores = runYawnModel(bytes, face.boundingBox);
      await updateHybridStatus(face, yawnScores);
    } catch (e) {
      debugPrint('Hybrid detection error: $e');
    }
    isDetecting = false;
  }

  List<double> runYawnModel(Uint8List imageBytes, Rect faceBox) {
    final input = imageToInputTensor(imageBytes, faceBox);
    final output = List.generate(1, (_) => List.filled(4, 0.0));
    interpreter!.run(input.reshape([1, 224, 224, 3]), output);
    return output[0];
  }

  Float32List imageToInputTensor(Uint8List imageBytes, Rect faceBox) {
    final raw = img.decodeImage(imageBytes);
    if (raw == null) throw Exception('Image decode failed');
    final decoded = img.bakeOrientation(raw);

    int x = faceBox.left.floor();
    int y = faceBox.top.floor();
    int w = faceBox.width.floor();
    int h = faceBox.height.floor();

    final padX = (w * 0.20).floor();
    final padY = (h * 0.25).floor();
    x = (x - padX).clamp(0, decoded.width - 1);
    y = (y - padY).clamp(0, decoded.height - 1);
    w = (w + padX * 2).clamp(1, decoded.width - x);
    h = (h + padY * 2).clamp(1, decoded.height - y);

    final crop = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    final resized = img.copyResize(crop, width: 224, height: 224);
    final input = Float32List(224 * 224 * 3);
    int index = 0;
    for (int yy = 0; yy < 224; yy++) {
      for (int xx = 0; xx < 224; xx++) {
        final p = resized.getPixel(xx, yy);
        input[index++] = p.b / 255.0;
        input[index++] = p.g / 255.0;
        input[index++] = p.r / 255.0;
      }
    }
    return input;
  }

  double calculateMouthOpenRatio(Face face) {
    final upperLip = face.contours[FaceContourType.upperLipTop]?.points;
    final lowerLip = face.contours[FaceContourType.lowerLipBottom]?.points;
    final faceWidth = face.boundingBox.width;

    if (upperLip == null || lowerLip == null || upperLip.isEmpty || lowerLip.isEmpty || faceWidth <= 0) {
      return 0.0;
    }

    double upperY = 0.0;
    for (final p in upperLip) {
      upperY += p.y;
    }
    upperY = upperY / upperLip.length;

    double lowerY = 0.0;
    for (final p in lowerLip) {
      lowerY += p.y;
    }
    lowerY = lowerY / lowerLip.length;

    final openDistance = (lowerY - upperY).abs();
    return openDistance / faceWidth;
  }

  Future<void> updateHybridStatus(Face face, List<double> scores) async {
    final left = face.leftEyeOpenProbability ?? 1.0;
    final right = face.rightEyeOpenProbability ?? 1.0;
    final headY = face.headEulerAngleY ?? 0.0;
    final headX = face.headEulerAngleX ?? 0.0;
    final mouthRatio = calculateMouthOpenRatio(face);

    final yawnScore = scores.length > 2 ? scores[2] : 0.0;
    final noYawnScore = scores.length > 3 ? scores[3] : 0.0;
    final yawnLabel = yawnScore > noYawnScore ? 'Yawn' : 'NoYawn';
    final yawnBest = yawnScore > noYawnScore ? yawnScore : noYawnScore;

    String newEyes = 'Open';
    String newYawn = 'No';
    String newHead = 'Forward';
    String newDriver = 'Normal';
    bool alert = false;
    String message = '';

    if (left < 0.35 && right < 0.35) {
      newEyes = 'Closed';
      newDriver = 'Drowsy';
      alert = true;
      message = 'Wake up. Please open your eyes and focus on driving.';
    }

    // Yawn is detected mainly from ML Kit mouth opening.
    // TFLite yawn is kept only as backup because it is weak on phone-camera crops.
    if (mouthRatio > 0.075 || (yawnLabel == 'Yawn' && yawnScore > 0.45)) {
      newYawn = 'Yes';
      newDriver = 'Fatigued';
      alert = true;
      message = 'You are yawning. Please take a break safely.';
    }

    // ML Kit head angles vary by phone/front camera, so thresholds are kept practical.
    if (headY > 18) {
      newHead = 'Looking Left';
      newDriver = 'Distracted';
      alert = true;
      message = 'Please look at the road.';
    } else if (headY < -18) {
      newHead = 'Looking Right';
      newDriver = 'Distracted';
      alert = true;
      message = 'Please look at the road.';
    } else if (headX.abs() > 12) {
      newHead = headX > 0 ? 'Head Down/Up' : 'Head Down/Up';
      newDriver = 'Distracted';
      alert = true;
      message = 'Please keep your head straight and look at the road.';
    }

    if (alert) {
      alertCount++;
      await speakAlert(message);
      await LocalStore.addHistory('Offline Alert', '$newDriver detected in hybrid mode');
    } else {
      alertCount = 0;
      emergencyHistoryAdded = false;
    }

    if (alertCount >= 3 && !emergencyHistoryAdded) {
      emergencyHistoryAdded = true;
      newDriver = 'Emergency';
      await speakAlert('Emergency alert triggered. Driver is not responding.');
      await LocalStore.addHistory('Offline Emergency', 'Three hybrid fatigue alerts detected');
    }

    if (!mounted) return;
    setState(() {
      detectionStatus = 'Face detected';
      leftEyeProb = left;
      rightEyeProb = right;
      eyes = newEyes;
      yawning = newYawn;
      headPose = newHead;
      driverStatus = newDriver;
      yawnModelResult = yawnLabel;
      yawnConfidence = yawnBest;
      yawnProb = yawnScore;
      noYawnProb = noYawnScore;
      mouthOpenRatio = mouthRatio;
      headXValue = headX;
      headYValue = headY;
    });
  }

  Future<void> speakAlert(String message) async {
    final now = DateTime.now();
    if (now.difference(lastVoiceAlert).inSeconds < 2) return;
    lastVoiceAlert = now;
    await flutterTts.stop();
    await flutterTts.speak(message);
  }

  Future<void> logout(BuildContext context) async {
    if (isCameraOn) await turnOffCamera();
    await LocalStore.addHistory('Logout', 'User logged out');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  void showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Color valueColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('normal') || lower.contains('open') || lower == 'no' || lower.contains('forward') || lower.contains('loaded') || lower.contains('detected')) return AppColors.green;
    if (lower.contains('closed') || lower.contains('emergency') || lower.contains('failed')) return AppColors.red;
    return AppColors.yellow;
  }

  Widget statusCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.35))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white70))),
          Flexible(child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget cameraBox() {
    return Container(
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.blue.withOpacity(0.55))),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isCameraOn && cameraController != null)
            Positioned.fill(child: CameraPreview(cameraController!))
          else
            Center(
              child: isCameraLoading
                  ? const CircularProgressIndicator(color: AppColors.blue)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white30, size: 90),
                        SizedBox(height: 16),
                        Text('Camera is off', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Tap Turn On Camera to start hybrid detection', style: TextStyle(color: Colors.white38, fontSize: 14)),
                      ],
                    ),
            ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(Icons.circle, color: isCameraOn ? AppColors.green : AppColors.red, size: 11),
                  const SizedBox(width: 7),
                  Text(isCameraOn ? 'HYBRID OFFLINE ACTIVE' : 'CAMERA OFF', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          if (isCameraOn)
            Center(child: Container(width: 190, height: 230, decoration: BoxDecoration(border: Border.all(color: AppColors.green, width: 3), borderRadius: BorderRadius.circular(18)))),
          if (isCameraOn)
            Positioned(
              bottom: 16,
              left: 16,
              child: Text('Eyes: $eyes\nYawn: $yawning\nHead: $headPose', style: const TextStyle(color: AppColors.green, fontSize: 13, height: 1.3, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('Hybrid Offline Dashboard', style: TextStyle(color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => logout(context))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text('AI Driver Fatigue Detection', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Eyes and head pose use ML Kit offline. Yawn uses your TFLite model. Python API is not required.', style: TextStyle(color: AppColors.textGrey, fontSize: 15, height: 1.4)),
          const SizedBox(height: 22),
          cameraBox(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: SizedBox(height: 52, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), icon: const Icon(Icons.videocam), label: const Text('Turn On Camera'), onPressed: isCameraOn ? null : turnOnCamera))),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(height: 52, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), icon: const Icon(Icons.videocam_off), label: const Text('Turn Off'), onPressed: isCameraOn ? turnOffCamera : null))),
            ],
          ),
          const SizedBox(height: 24),
          statusCard('Detection', detectionStatus, Icons.face_retouching_natural, valueColor(detectionStatus)),
          statusCard('TFLite Model', modelStatus, Icons.memory, valueColor(modelStatus)),
          statusCard('Driver Status', driverStatus, Icons.health_and_safety, valueColor(driverStatus)),
          statusCard('Eyes', eyes, Icons.remove_red_eye, valueColor(eyes)),
          statusCard('Left Eye ML Kit', '${(leftEyeProb * 100).toStringAsFixed(1)}%', Icons.visibility, AppColors.blue),
          statusCard('Right Eye ML Kit', '${(rightEyeProb * 100).toStringAsFixed(1)}%', Icons.visibility, AppColors.blue),
          statusCard('Yawning', yawning, Icons.face, valueColor(yawning)),
          statusCard('Yawn Model Result', yawnModelResult, Icons.model_training, valueColor(yawnModelResult)),
          statusCard('Yawn Prob', '${(yawnProb * 100).toStringAsFixed(1)}%', Icons.face, AppColors.yellow),
          statusCard('NoYawn Prob', '${(noYawnProb * 100).toStringAsFixed(1)}%', Icons.sentiment_satisfied, AppColors.blue),
          statusCard('Mouth Open Ratio', mouthOpenRatio.toStringAsFixed(3), Icons.record_voice_over, AppColors.yellow),
          statusCard('Head Pose', headPose, Icons.person_pin_circle, valueColor(headPose)),
          statusCard('Head X Angle', headXValue.toStringAsFixed(1), Icons.swap_vert, AppColors.blue),
          statusCard('Head Y Angle', headYValue.toStringAsFixed(1), Icons.swap_horiz, AppColors.blue),
          statusCard('Alert Count', '$alertCount / 3', Icons.warning, alertCount >= 3 ? AppColors.red : AppColors.yellow),
          statusCard('Voice Alert', 'Phone Speaker', Icons.volume_up, AppColors.green),
        ],
      ),
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});
  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  List<String> contacts = [];
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => contacts = prefs.getStringList('emergency_contacts') ?? []);
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergency_contacts', contacts);
  }

  Future<void> addOrUpdateContact() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return showMessage('Enter name and phone number');
    if (editingIndex == null && contacts.length >= 15) return showMessage('Maximum 15 emergency contacts allowed');
    final wasEditing = editingIndex != null;
    setState(() {
      if (editingIndex == null) {
        contacts.add('$name|$phone');
      } else {
        contacts[editingIndex!] = '$name|$phone';
        editingIndex = null;
      }
      nameController.clear();
      phoneController.clear();
    });
    await saveContacts();
    await LocalStore.addHistory(wasEditing ? 'Contact Updated' : 'Contact Added', '$name saved as emergency contact');
    showMessage('Contact saved');
  }

  Future<void> deleteContact(int index) async {
    final name = contacts[index].split('|').first;
    setState(() => contacts.removeAt(index));
    await saveContacts();
    await LocalStore.addHistory('Contact Deleted', '$name removed from emergency contacts');
    showMessage('Contact deleted');
  }

  void editContact(int index) {
    final parts = contacts[index].split('|');
    setState(() {
      editingIndex = index;
      nameController.text = parts.isNotEmpty ? parts[0] : '';
      phoneController.text = parts.length > 1 ? parts[1] : '';
    });
  }

  void showMessage(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget inputBox(String hint, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: AppColors.card, prefixIcon: Icon(icon, color: AppColors.blue), hintText: hint, hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
    );
  }

  Widget contactCard(int index) {
    final parts = contacts[index].split('|');
    final name = parts.isNotEmpty ? parts[0] : 'Unknown';
    final phone = parts.length > 1 ? parts[1] : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.blue.withOpacity(0.15), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(phone, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 14))])),
          IconButton(icon: const Icon(Icons.edit, color: AppColors.yellow), onPressed: () => editContact(index)),
          IconButton(icon: const Icon(Icons.delete, color: AppColors.red), onPressed: () => deleteContact(index)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = editingIndex != null;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          inputBox('Contact Name', Icons.person, nameController),
          const SizedBox(height: 14),
          inputBox('Phone Number', Icons.phone, phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 18),
          SizedBox(height: 55, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isEditing ? AppColors.yellow : AppColors.blue, foregroundColor: isEditing ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), icon: Icon(isEditing ? Icons.save : Icons.person_add), label: Text(isEditing ? 'UPDATE CONTACT' : 'ADD CONTACT', style: const TextStyle(fontWeight: FontWeight.bold)), onPressed: addOrUpdateContact)),
          const SizedBox(height: 24),
          Text('Saved Contacts (${contacts.length}/15)', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          if (contacts.isEmpty)
            Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)), child: const Center(child: Text('No emergency contacts added yet', style: TextStyle(color: Colors.white54))))
          else
            ...List.generate(contacts.length, contactCard),
        ],
      ),
    );
  }
}

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});
  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => history = prefs.getStringList('alert_history') ?? []);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alert_history');
    if (!mounted) return;
    setState(() => history = []);
  }

  Widget alertCard(String item) {
    final parts = item.split('|');
    final title = parts.isNotEmpty ? parts[0] : 'Alert';
    final details = parts.length > 1 ? parts[1] : '';
    final time = parts.length > 2 ? parts[2] : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.yellow.withOpacity(0.35))),
      child: Row(children: [const Icon(Icons.notifications, color: AppColors.yellow), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(details, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 4), Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12))]))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, title: const Text('Alert History', style: TextStyle(color: Colors.white)), actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: loadHistory), IconButton(icon: const Icon(Icons.delete_sweep, color: AppColors.red), onPressed: history.isEmpty ? null : clearHistory)]),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        const Text('Recent Alerts', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        if (history.isEmpty) Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)), child: const Center(child: Text('No alert history yet', style: TextStyle(color: Colors.white54)))) else ...history.map(alertCard),
      ]),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget settingTile(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)),
      child: Row(children: [Icon(icon, color: color, size: 30), const SizedBox(width: 14), Expanded(child: Text(title, style: const TextStyle(color: Colors.white70))), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.bg, title: const Text('Settings', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text('View-only system settings', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          settingTile('Voice Alerts', 'ON', Icons.volume_up, AppColors.green),
          settingTile('Eye Detection', 'ML Kit', Icons.remove_red_eye, AppColors.green),
          settingTile('Head Pose', 'ML Kit', Icons.person_pin_circle, AppColors.green),
          settingTile('Yawn Detection', 'TFLite Model', Icons.model_training, AppColors.blue),
          settingTile('Internet Required', 'NO', Icons.wifi_off, AppColors.green),
          settingTile('Emergency After', '3 Alerts', Icons.warning, AppColors.red),
        ],
      ),
    );
  }
}
