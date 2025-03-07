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
  bool _hasJoined = false,
        switchCamera = true,
        switchRender = true,
        openCamera = true,
        muteCamera = false,
        muteAllRemoteVideo = false;
  int? _remoteUID;
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  @override
  void initState() {
    _consultController = TextEditingController();
    super.initState();
    _initAgoraEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupAgoraEngine();
  }

  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _initAgoraEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "<-- Insert app Id -->",
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() => _hasJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() => _remoteUID = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() => _remoteUID = null);
        },
      ),
    );
    _engine.registerEventHandler(_rtcEngineEventHandler);
    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: "add token",
      channelId: _consultController.text, // based on agora doc sample code
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> _leaveChannel() async {
    await _engine.leaveChannel();
    setState(() {
      _hasJoined = false;
      _remoteUID = null;
      openCamera = true;
      muteCamera = false;
      muteAllRemoteVideo = false;
    });
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
    setState(() => switchCamera = !switchCamera);
  }

  _openCamera() async {
    await _engine.enableLocalVideo(!openCamera);
    setState(() {
      openCamera = !openCamera;
    });
  }

  _muteCamera() async {
    await _engine.muteLocalVideoStream(!muteCamera);
    setState(() {
      muteCamera = !muteCamera;
    });
  }

  _muteAllRemoteVideo() async {
    await _engine.muteAllRemoteVideoStreams(!muteAllRemoteVideo);
    setState(() {
      muteAllRemoteVideo = !muteAllRemoteVideo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting in Session"),
      ),
       body: Stack(
        children: [
          //stats tracker
          Align(
            alignment: Alignment.bottomRight,
          ),
        ],
       )
      );
  }
}
