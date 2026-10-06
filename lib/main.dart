import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(SadaApp());

class SadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SADA',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Cairo'),
      home: LoginScreen(),
    );
  }
}

// شاشة تسجيل الدخول بالتلفون/ايميل
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool isPhone = true;

  Future<void> _login() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('اكمل البيانات')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_contact', _phoneController.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22C55E),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text('صـدى SADA', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextField(controller: _nameController, decoration: InputDecoration(hintText: 'اسمك', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SizedBox(height: 12),
            Row(children: [
              ChoiceChip(label: Text('تلفون'), selected: isPhone, onSelected: (v){setState(()=>isPhone=true);}),
              SizedBox(width:8),
              ChoiceChip(label: Text('ايميل'), selected: !isPhone, onSelected: (v){setState(()=>isPhone=false);}),
            ]),
            SizedBox(height:12),
            TextField(controller: _phoneController, keyboardType: isPhone? TextInputType.phone : TextInputType.emailAddress, decoration: InputDecoration(hintText: isPhone? 'رقم التلفون' : 'الايميل', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('دخول', style: TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),
      ),
    );
  }
}

// شاشة الغرف
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomController = TextEditingController(text: 'sada1');
  final _jitsi = JitsiMeet();
  String userName = '';

  @override
  void initState(){_loadUser(); super.initState();}
  _loadUser() async {final p=await SharedPreferences.getInstance(); setState(()=>userName=p.getString('user_name')??'');}

  Future<void> _join() async {
    if(_roomController.text.trim().isEmpty) return;
    var options = JitsiMeetConferenceOptions(
      roomName: _roomController.text.trim().toLowerCase().replaceAll(' ', ''),
      serverUrl: 'https://meet.jit.si',
      userInfo: JitsiMeetUserInfo(displayName: userName, email: ''),
      configOverrides: {
        "startWithAudioMuted": false, // الصوت شغال طوالي
        "startWithVideoMuted": false, // الكاميرا شغالة
        "enableLobbyChat": false,
        "prejoinPageEnabled": false, // مافي انتظار
        "disableInviteFunctions": true,
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
        "lobby-mode.enabled": false,
        "prejoinpage.enabled": false,
        "audioMute.enabled": true,
        "videoMute.enabled": true,
        "chat.enabled": true,
        "invite.enabled": false,
      },
    );
    await _jitsi.join(options);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('مرحبا $userName'), backgroundColor: Color(0xFF22C55E)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Text('اكتب اسم الغرفة وشاركو مع صديقك', style: TextStyle(fontSize: 16)),
          SizedBox(height:20),
          TextField(controller: _roomController, decoration: InputDecoration(labelText: 'اسم الغرفة (مثلا sada1)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.video_call))),
          SizedBox(height:20),
          ElevatedButton(onPressed: _join, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF22C55E), minimumSize: Size(double.infinity, 55)), child: Text('ابدأ المكالمة - فيديو وصوت', style: TextStyle(fontSize:18))),
          SizedBox(height:20),
          Card(child: ListTile(leading: Icon(Icons.info), title: Text('كيف يدخل صديقك؟'), subtitle: Text('1. يثبت نفس التطبيق\n2. يكتب نفس اسم الغرفة بالضبط\n3. الصوت والكاميرا حيشتغلو اوتوماتيك\n4. في المكالمة اسحب الشاشة لفوق لتلقي ازرار: مايك، كاميرا، قلب الكاميرا'))),
        ]),
      ),
    );
  }
}
