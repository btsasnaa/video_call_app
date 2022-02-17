import 'package:flutter/material.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

final appId = '2b5bb6a562034ebebccaa0299e8e5217';
// app certificate e61ad8c2902f4111a37dd4f4e73d946f
// Temp Token
final token =
    '0062b5bb6a562034ebebccaa0299e8e5217IABroXEVvpxZkeyi4y/slnL2mdhnBAXxBMTk0D9a6NRrfdrKY/oAAAAAEACEYx7AYmwPYgEAAQBhbA9i';

void main() {
  runApp(MaterialApp(home: MyApp1()));
}

class MyApp1 extends StatefulWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  int? _remoteUid;
  RtcEngine? _engine;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(appId));

    await _engine!.enableVideo();

    _engine!.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          print('joinChannelSuccess');
        },
        userJoined: (uid, elapsed) {
          print('userJoined');
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (uid, reason) {
          print('userOffline');
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine!.joinChannel(token, 'videochannel1', null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora video call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 100,
              width: 100,
              child: Center(
                child: _renderLocalPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLocalPreview() {
    return RtcLocalView.SurfaceView();
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
