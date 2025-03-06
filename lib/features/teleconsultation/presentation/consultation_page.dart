import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DoctorConsultation extends StatefulWidget {
  const DoctorConsultation({Key? key}) : super(key: key);

  @override
  State<DoctorConsultation> createState() => _DoctorConsultationState();
}

class _DoctorConsultationState extends State<DoctorConsultation> {
  late final RtcEngine _engine;
  late TextEditingController _consultController;
  bool hasJoined = false;

  @override
  void initState() {
    _consultController = TextEditingController();
    super.initState();
    _initAgoraEngine();
  }

  Future<void> _initAgoraEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "<-- Insert app Id -->",
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: "add token",
      channelId: _consultController.text,// based on agora doc sample code
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeVideo:
            true, // Automatically subscribe to all video streams
        autoSubscribeAudio:
            true, // Automatically subscribe to all audio streams
        publishCameraTrack: true, // Publish camera-captured video
        publishMicrophoneTrack: true, // Publish microphone-captured audio
        // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> _cleanupAgoraEngine() async {
  await _engine.leaveChannel();
  await _engine.release();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [],
      ),
    );
  }
}
