import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = String.fromEnvironment('AGORA_APP_ID', defaultValue: '252279af7bdd4045b3fba9d7df7a0333');

void main() => runApp(const SadaApp());

class SadaApp extends StatelessWidget {
  const SadaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صدى',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ctrl = TextEditingController(text: 'sada-room-1');
  bool _isVideo = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صدى - SADA'), backgroundColor: const Color(0xFF0E7A4C), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.call, size: 80, color: Color(0xFF0E7A4C)),
            const SizedBox(height: 20),
            const Text('مرحبا بك في صدى', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'اسم الغرفة', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: RadioListTile(value: true, groupValue: _isVideo, onChanged: (v)=>setState(()=>_isVideo=v!), title: const Text('فيديو'))),
              Expanded(child: RadioListTile(value: false, groupValue: _isVideo, onChanged: (v)=>setState(()=>_isVideo=v!), title: const Text('صوت'))),
            ]),
            const Spacer(),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E7A4C), padding: const EdgeInsets.all(16)),
              onPressed: () async {
                await [Permission.microphone, Permission.camera].request();
                if(!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(channel: _ctrl.text, isVideo: _isVideo)));
              },
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('ابدأ المكالمة', style: TextStyle(color: Colors.white, fontSize: 18)),
            )),
          ],
        ),
      ),
    );
  }
}

class CallPage extends StatefulWidget {
  final String channel; final bool isVideo;
  const CallPage({super.key, required this.channel, required this.isVideo});
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late final RtcEngine _engine;
  bool _joined = false; int? _remote;
  @override
  void initState() { super.initState(); _init(); }
  Future<void> _init() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (_, __) => setState(()=>_joined=true),
      onUserJoined: (_, uid, __) => setState(()=>_remote=uid),
      onUserOffline: (_, __, ___) => setState(()=>_remote=null),
    ));
    await _engine.enableVideo(); await _engine.startPreview();
    await _engine.joinChannel(token: '', channelId: widget.channel, uid: 0, options: const ChannelMediaOptions());
  }
  @override
  void dispose() { _engine.leaveChannel(); _engine.release(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      Center(child: _remote==null ? const Text('في انتظار صديقك...\nارسل له اسم الغرفة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)) : AgoraVideoView(controller: VideoViewController.remote(rtcEngine: _engine, canvas: VideoCanvas(uid: _remote), connection: RtcConnection(channelId: widget.channel)))),
      Positioned(top: 40, right: 20, width: 110, height: 150, child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AgoraVideoView(controller: VideoViewController(rtcEngine: _engine, canvas: const VideoCanvas(uid: 0))))),
      Positioned(bottom: 40, left: 0, right: 0, child: Center(child: FloatingActionButton(backgroundColor: Colors.red, onPressed: ()=>Navigator.pop(context), child: const Icon(Icons.call_end)))),
      if(!_joined) const Center(child: CircularProgressIndicator()),
    ]));
  }
}
