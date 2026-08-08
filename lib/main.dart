import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const DriverGuardApp());

class DriverGuardApp extends StatelessWidget {
  const DriverGuardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DriverGuard AI',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF07111B),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF48E08B), brightness: Brightness.dark),
      useMaterial3: true,
      fontFamily: 'sans',
    ),
    home: const _HomeScreen(),
  );
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();
  void _start(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const _MonitoringScreen()));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF07111B),
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(child: Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF102A25), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF1D4A3A))), child: const Icon(Icons.shield_rounded, color: Color(0xFF48E08B), size: 27)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DriverGuard', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 2), Text('INTELLIGENT DRIVER SAFETY', style: TextStyle(fontSize: 9, letterSpacing: 1.4, color: Color(0xFF708899), fontWeight: FontWeight.w800))])),
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0D1D2A), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.notifications_none_rounded, color: Color(0xFFAEC1CF), size: 21)),
            ])),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(child: Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF123A37), Color(0xFF0B2430), Color(0xFF0A1823)]),
                border: Border.all(color: const Color(0xFF1B5148)),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0x2248E08B), borderRadius: BorderRadius.circular(30)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 7, color: Color(0xFF48E08B)), SizedBox(width: 7), Text('SYSTEM ONLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF48E08B), letterSpacing: .8))])),
                  const Spacer(),
                  const Text('LOCAL AI', style: TextStyle(fontSize: 9, color: Color(0xFF7D9AA9), fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                ]),
                const SizedBox(height: 27),
                const Text('Your safety,
monitored in real time.', style: TextStyle(fontSize: 30, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.6)),
                const SizedBox(height: 12),
                const Text('DriverGuard watches for fatigue and distraction while keeping analysis on your device.', style: TextStyle(color: Color(0xFF9DB3C0), height: 1.5, fontSize: 13)),
                const SizedBox(height: 22),
                SizedBox(width: double.infinity, height: 58, child: FilledButton.icon(onPressed: () => _start(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF48E08B), foregroundColor: const Color(0xFF06130E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))), icon: const Icon(Icons.play_circle_outline_rounded, size: 23), label: const Text('Start safety monitoring', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)))),
              ]),
            )),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(child: Row(children: [
              Expanded(child: _StatCard(icon: Icons.memory_rounded, value: 'ON', label: 'AI ENGINE', accent: const Color(0xFF55B8FF))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.wifi_off_rounded, value: 'LOCAL', label: 'PROCESSING', accent: const Color(0xFF48E08B))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.speed_rounded, value: 'LIVE', label: 'ANALYSIS', accent: const Color(0xFFB38CFF))),
            ])),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: SliverToBoxAdapter(child: Row(children: [const Expanded(child: Text('Protection system', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Text('4 safeguards', style: TextStyle(fontSize: 11, color: Color(0xFF718899), fontWeight: FontWeight.w700))])),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverToBoxAdapter(child: Container(
              decoration: BoxDecoration(color: const Color(0xFF0B1A27), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF173043))),
              child: const Column(children: [
                _ProtectionTile(icon: Icons.visibility_rounded, title: 'Eye closure', subtitle: 'Drowsiness & fatigue', color: Color(0xFF55B8FF)),
                _ProtectionTile(icon: Icons.face_retouching_natural_rounded, title: 'Yawning', subtitle: 'Repeated fatigue signals', color: Color(0xFF48E08B)),
                _ProtectionTile(icon: Icons.center_focus_strong_rounded, title: 'Head position', subtitle: 'Left, right & off-center', color: Color(0xFFB38CFF)),
                _ProtectionTile(icon: Icons.emergency_rounded, title: 'Emergency response', subtitle: 'Voice + emergency message', color: Color(0xFFFF6575), last: true),
              ]),
            )),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color accent;
  const _StatCard({required this.icon, required this.value, required this.label, required this.accent});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), decoration: BoxDecoration(color: const Color(0xFF0B1A27), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF173043))), child: Column(children: [Icon(icon, color: accent, size: 20), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: accent)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 8, letterSpacing: .6, color: Color(0xFF718899), fontWeight: FontWeight.w800))]));
}

class _ProtectionTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final bool last;
  const _ProtectionTile({required this.icon, required this.title, required this.subtitle, required this.color, this.last = false});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15), decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: Color(0xFF142B3A)))), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 21)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF718899)))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0x163CD98A), borderRadius: BorderRadius.circular(10)), child: const Text('READY', style: TextStyle(fontSize: 8, color: Color(0xFF48E08B), fontWeight: FontWeight.w900)))]));
}

class _MonitoringScreen extends StatefulWidget { const _MonitoringScreen(); @override State<_MonitoringScreen> createState() => _MonitoringScreenState(); }

class _MonitoringScreenState extends State<_MonitoringScreen> {
  CameraController? _camera; FaceDetector? _detector; final FlutterTts _tts = FlutterTts(); Timer? _timer;
  bool _running = false, _processing = false, _emergencyStarted = false;
  String _status = 'Camera ready', _eyes = 'Open', _yawn = 'No', _head = 'Forward', _driver = 'Safe', _alertCause = 'No active warning', _emergencyStatus = 'Standby';
  double _left = 1, _right = 1, _mouth = 0, _headX = 0, _headY = 0;
  int _alerts = 0; String _lastAlertType = ''; DateTime _lastAlert = DateTime.fromMillisecondsSinceEpoch(0);
  static const MethodChannel _smsChannel = MethodChannel('auto_sms_channel');

  @override void initState() { super.initState(); _detector = FaceDetector(options: FaceDetectorOptions(enableClassification: true, enableContours: true, enableTracking: true)); _tts.setLanguage('en-IN'); _tts.setSpeechRate(.45); _tts.setVolume(1); }
  @override void dispose() { _timer?.cancel(); _camera?.dispose(); _detector?.close(); _tts.stop(); super.dispose(); }

  Future<void> _start() async {
    if (_running) return;
    try {
      final cameras = await availableCameras(); if (cameras.isEmpty) throw Exception('No camera');
      final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      final controller = CameraController(front, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await controller.initialize(); if (!mounted) { await controller.dispose(); return; }
      setState(() { _camera = controller; _running = true; _status = 'Monitoring active'; _alerts = 0; _emergencyStarted = false; _emergencyStatus = 'Standby'; });
      _timer?.cancel(); _timer = Timer.periodic(const Duration(milliseconds: 550), (_) => _captureAndAnalyze());
    } catch (_) { if (mounted) setState(() => _status = 'Camera unavailable'); }
  }

  Future<void> _stop() async { _timer?.cancel(); _timer = null; final c = _camera; _camera = null; if (mounted) setState(() { _running = false; _status = 'Monitoring stopped'; _driver = 'Safe'; _alerts = 0; _emergencyStarted = false; _emergencyStatus = 'Standby'; }); await c?.dispose(); }

  Future<void> _captureAndAnalyze() async {
    if (!_running || _processing || _camera == null || !_camera!.value.isInitialized) return; _processing = true;
    try { final image = await _camera!.takePicture(); final faces = await _detector!.processImage(InputImage.fromFilePath(image.path)); if (faces.isNotEmpty) { await _update(faces.first); } else if (mounted) setState(() { _status = 'Searching for driver'; _driver = 'No Face'; }); } catch (_) {} finally { _processing = false; }
  }

  double _mouthRatio(Face face) { final upper = face.contours[FaceContourType.upperLipTop]?.points; final lower = face.contours[FaceContourType.lowerLipBottom]?.points; if (upper == null || lower == null || upper.isEmpty || lower.isEmpty || face.boundingBox.width <= 0) return 0; final uy = upper.map((p) => p.y).reduce((a,b) => a+b) / upper.length; final ly = lower.map((p) => p.y).reduce((a,b) => a+b) / lower.length; return (ly-uy).abs()/face.boundingBox.width; }

  Future<void> _update(Face face) async {
    final double left=(face.leftEyeOpenProbability ?? 1).toDouble(), right=(face.rightEyeOpenProbability ?? 1).toDouble(), hx=(face.headEulerAngleX ?? 0).toDouble(), hy=(face.headEulerAngleY ?? 0).toDouble(), mouth=_mouthRatio(face);
    final bool eyesClosed=left<.35&&right<.35, yawn=mouth>.075, lookingLeft=hy>12, lookingRight=hy<-12, headOffCenter=hx.abs()>12;
    String eyes=eyesClosed?'Closed':'Open', yawnText=yawn?'Yes':'No', head='Forward', driver='Safe', cause='No active warning', type='', message='';
    if (eyesClosed) { driver='Drowsy'; cause='Eyes closed'; type='eyes'; message='Wake up. Please open your eyes and focus on driving.'; }
    if (yawn) { driver='Fatigued'; cause='Yawning detected'; type='yawn'; message='You are yawning. Please take a break safely.'; }
    if (lookingLeft) { head='Looking Left'; driver='Distracted'; cause='Head turned left'; type='head'; message='Please look at the road.'; } else if (lookingRight) { head='Looking Right'; driver='Distracted'; cause='Head turned right'; type='head'; message='Please look at the road.'; } else if (headOffCenter) { head='Off Center'; driver='Distracted'; cause='Head position changed'; type='head'; message='Please keep your head aligned and look at the road.'; }
    if (type.isNotEmpty) { await _registerAlert(type,message); } else if (_alerts>0) { _alerts=0; _lastAlertType=''; _emergencyStarted=false; _emergencyStatus='Standby'; }
    if (!mounted) return; setState(() { _status='Face detected'; _eyes=eyes; _yawn=yawnText; _head=head; _driver=driver; _alertCause=cause; _left=left; _right=right; _mouth=mouth; _headX=hx; _headY=hy; });
  }

  Future<void> _registerAlert(String type,String message) async { final now=DateTime.now(); if(now.difference(_lastAlert).inSeconds<2)return; _lastAlert=now; _lastAlertType=type; _alerts++; await _tts.stop(); await _tts.speak(message); if(_alerts>=3&&!_emergencyStarted)await _triggerEmergency(type); if(mounted)setState(()=>_emergencyStatus=_emergencyStarted?'Emergency triggered':'Alert $_alerts / 3'); }

  Future<void> _triggerEmergency(String type) async {
    _emergencyStarted=true;
    final String message=type=='yawn'?'🚨 DRIVERGUARD EMERGENCY ALERT\n\nRepeated yawning detected 3 times.\nPossible driver fatigue detected.\n\nPlease contact the driver immediately.':type=='eyes'?'🚨 DRIVERGUARD EMERGENCY ALERT\n\nRepeated eye closure detected 3 times.\nPossible driver fatigue detected.\n\nPlease contact the driver immediately.':'🚨 DRIVERGUARD EMERGENCY ALERT\n\nRepeated distraction/head-position alerts detected 3 times.\nPossible driver distraction detected.\n\nPlease contact the driver immediately.';
    if(mounted)setState((){_driver='Emergency';_alertCause='3 consecutive alerts';_emergencyStatus='Emergency triggered';}); await _tts.stop(); await _tts.speak('Emergency alert triggered. Please contact the driver immediately.'); await _sendEmergencyMessage(message);
  }

  Future<void> _sendEmergencyMessage(String message) async {
    final prefs=await SharedPreferences.getInstance(); final contacts=prefs.getStringList('emergency_contacts')??<String>[]; if(contacts.isEmpty){if(mounted)setState(()=>_emergencyStatus='No emergency contacts saved');return;}
    final permission=await Permission.sms.request(); int sent=0;
    for(final contact in contacts){final parts=contact.split('|'); final phone=parts.length>1?parts[1].trim():contact.trim(); if(phone.isEmpty)continue; bool ok=false; if(permission.isGranted){try{ok=await _smsChannel.invokeMethod('sendSms',{'phone':phone,'message':message})==true;}catch(_){}} if(!ok){try{final uri=Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');if(await canLaunchUrl(uri)){await launchUrl(uri);ok=true;}}catch(_){}} if(ok)sent++;}
    if(mounted)setState(()=>_emergencyStatus=sent>0?'Emergency message sent':'Emergency message failed');
  }

  Color get _statusColor=>_driver=='Safe'?const Color(0xFF48E08B):_driver=='Emergency'?const Color(0xFFFF5969):const Color(0xFFFFB84D);
  Widget _signal(String title,String value,IconData icon,Color color)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFF0B1A27),borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0xFF173043))),child:Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:color.withOpacity(.1),borderRadius:BorderRadius.circular(11)),child:Icon(icon,color:color,size:20)),const SizedBox(width:12),Expanded(child:Text(title,style:const TextStyle(color:Color(0xFFAEC0CE),fontWeight:FontWeight.w600))),Text(value,style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:12))]));

  @override
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFF07111B),
    appBar:AppBar(backgroundColor:const Color(0xFF07111B),surfaceTintColor:Colors.transparent,title:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Safety monitor',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text('DRIVERGUARD AI',style:TextStyle(fontSize:8,color:Color(0xFF708899),letterSpacing:1.2,fontWeight:FontWeight.w800))]),actions:[Padding(padding:const EdgeInsets.only(right:18),child:Center(child:Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:const Color(0x1600D97A),borderRadius:BorderRadius.circular(20)),child:Text(_running?'● LIVE':'○ IDLE',style:TextStyle(color:_running?const Color(0xFF48E08B):const Color(0xFF8298A8),fontSize:10,fontWeight:FontWeight.w900))))]),
    body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,32),children:[
      Container(height:285,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:const Color(0xFF0B1A27),borderRadius:BorderRadius.circular(25),border:Border.all(color:_running?const Color(0xFF2B7457):const Color(0xFF173043))),child:Stack(children:[Positioned.fill(child:_camera!=null&&_camera!.value.isInitialized?CameraPreview(_camera!):const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.camera_front_rounded,size:50,color:Color(0xFF456477)),SizedBox(height:12),Text('Camera preview',style:TextStyle(fontSize:14,fontWeight:FontWeight.w800)),SizedBox(height:5),Text('Start monitoring to activate AI analysis',style:TextStyle(fontSize:11,color:Color(0xFF718899))]))),Positioned(top:14,left:14,child:Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:const Color(0xCC07111B),borderRadius:BorderRadius.circular(12)),child:Text(_running?'ANALYZING':'STANDBY',style:TextStyle(fontSize:8,color:_running?const Color(0xFF48E08B):const Color(0xFF91A7B5),fontWeight:FontWeight.w900,letterSpacing:1)))),Positioned(bottom:14,left:14,right:14,child:Row(children:[_MiniLive('EYES',_eyes),const SizedBox(width:8),_MiniLive('YAWN',_yawn),const SizedBox(width:8),_MiniLive('HEAD',_head)]))])),
      const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:LinearGradient(colors:[_statusColor.withOpacity(.16),const Color(0xFF0B1A27)]),borderRadius:BorderRadius.circular(22),border:Border.all(color:_statusColor.withOpacity(.4))),child:Row(children:[Container(width:50,height:50,decoration:BoxDecoration(color:_statusColor.withOpacity(.12),shape:BoxShape.circle),child:Icon(_driver=='Safe'?Icons.verified_rounded:_driver=='Emergency'?Icons.emergency_rounded:Icons.warning_amber_rounded,color:_statusColor,size:26)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('CURRENT SAFETY STATE',style:TextStyle(fontSize:8,color:Color(0xFF718899),letterSpacing:1.1,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(_driver.toUpperCase(),style:TextStyle(fontSize:21,color:_statusColor,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(_alertCause,style:const TextStyle(fontSize:10,color:Color(0xFF9BB0C1)))])),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text('$_alerts',style:TextStyle(fontSize:27,color:_statusColor,fontWeight:FontWeight.w900)),const Text('ALERTS',style:TextStyle(fontSize:8,color:Color(0xFF718899),fontWeight:FontWeight.w800))])])),
      const SizedBox(height:10),
      Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:11),decoration:BoxDecoration(color:_emergencyStarted?const Color(0x22FF5969):const Color(0xFF0B1A27),borderRadius:BorderRadius.circular(15),border:Border.all(color:_emergencyStarted?const Color(0x66FF5969):const Color(0xFF173043))),child:Row(children:[Icon(_emergencyStarted?Icons.emergency_rounded:Icons.shield_outlined,size:18,color:_emergencyStarted?const Color(0xFFFF5969):const Color(0xFF48E08B)),const SizedBox(width:9),Expanded(child:Text(_emergencyStatus,style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:_emergencyStarted?const Color(0xFFFF7A87):const Color(0xFF9BB0C1)))),const Text('3 alerts → emergency',style:TextStyle(fontSize:9,color:Color(0xFF718899),fontWeight:FontWeight.w700))])),
      const SizedBox(height:15),
      const Text('Detection signals',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:9),
      _signal('Eye state',_eyes,Icons.visibility_rounded,_eyes=='Open'?const Color(0xFF48E08B):const Color(0xFFFFB84D)),const SizedBox(height:8),_signal('Yawning',_yawn,Icons.face_retouching_natural_rounded,_yawn=='No'?const Color(0xFF48E08B):const Color(0xFFFFB84D)),const SizedBox(height:8),_signal('Head position',_head,Icons.center_focus_strong_rounded,_head=='Forward'?const Color(0xFF48E08B):const Color(0xFFFFB84D)),
      const SizedBox(height:15),
      Row(children:[Expanded(child:FilledButton.icon(onPressed:_running?null:_start,style:FilledButton.styleFrom(backgroundColor:const Color(0xFF48E08B),foregroundColor:const Color(0xFF06130E),minimumSize:const Size.fromHeight(53),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),icon:const Icon(Icons.play_arrow_rounded),label:const Text('START MONITORING',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900)))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:_running?_stop:null,style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(53),side:const BorderSide(color:Color(0xFF294254)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),icon:const Icon(Icons.stop_rounded),label:const Text('STOP',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900))))]),
      const SizedBox(height:12),Text(_status,textAlign:TextAlign.center,style:const TextStyle(color:Color(0xFF718899),fontSize:10,fontWeight:FontWeight.w700)),const SizedBox(height:5),Text('Eye ${(_left*100).toStringAsFixed(0)}% / ${(_right*100).toStringAsFixed(0)}%  •  Mouth ${(_mouth*100).toStringAsFixed(1)}%  •  Head X ${_headX.toStringAsFixed(1)}°  Y ${_headY.toStringAsFixed(1)}°',textAlign:TextAlign.center,style:const TextStyle(color:Color(0xFF526D7D),fontSize:9)),
    ]),
  );
}

class _MiniLive extends StatelessWidget { final String label,value; const _MiniLive(this.label,this.value); @override Widget build(BuildContext context)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:8,horizontal:9),decoration:BoxDecoration(color:const Color(0xDD07111B),borderRadius:BorderRadius.circular(11)),child:Column(children:[Text(label,style:const TextStyle(fontSize:7,color:Color(0xFF718899),fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(value,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w800))]))); }
