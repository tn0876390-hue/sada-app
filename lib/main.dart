import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

void main() {
  runApp(const SadaApp());
}

class SadaApp extends StatelessWidget {
  const SadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SADA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final _roomController = TextEditingController(text: "sada-room");
  final _nameController = TextEditingController(text: "User");
  final _jitsiMeet = JitsiMeet();

  Future<void> _joinRoom() async {
    String room = _roomController.text.trim().toLowerCase().replaceAll(' ', '');
    if (room.isEmpty) {
      room = "sada-room";
    }

    var options = JitsiMeetConferenceOptions(
      room: room,
      serverURL: "https://meet.jit.si",
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "subject": "SADA Call",
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
        "chat.enabled": true,
        "invite.enabled": false,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: _nameController.text,
        email: "user@sada.com",
      ),
    );

    await _jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SADA - Video Call")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "اسمك"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: "اسم الغرفة"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinRoom,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("انضم للمكالمة"),
            ),
          ],
        ),
      ),
    );
  }
}
