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
  bool _hasJoined = false, openCamera = true, muteCamera = false, muteAllRemoteVideo = false;
  int? _remoteUID;

  // Replace these with secure methods to store/retrieve credentials
  final String appId = "bc06bf6bab7645abbc9b9d56db3f2868";
  final String token = "b18838802df04970aa5bc4fc96f54d4f";

  @override
  void initState() {
    _consultController = TextEditingController();
    super.initState();
    _initAgoraEngine();
  }

  @override
  void dispose() {
    _consultController.dispose();
    _cleanupAgoraEngine();
    super.dispose();
  }

  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _initAgoraEngine() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileCommunication),
    );

    // Set up local video before preview
    await _engine.setupLocalVideo(const VideoCanvas(uid: 0));

    // Disable face detection warnings
    await _engine.setParameters("{\"che.video.face_detect\": false}");
    await _engine.setParameters("{\"che.video.low_camera\": true}");

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
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() => _remoteUID = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future<void> _joinChannel() async {
    if (_consultController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Channel ID")),
      );
      return;
    }

    try {
      debugPrint("Joining channel: ${_consultController.text}");
      await _engine.joinChannel(
        token: token,
        channelId: _consultController.text,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint("Error joining channel: $e");
    }
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

  Future<void> _toggleCamera() async {
    await _engine.enableLocalVideo(!openCamera);
    setState(() => openCamera = !openCamera);
  }

  Future<void> _muteCameraToggle() async {
    await _engine.muteLocalVideoStream(!muteCamera);
    setState(() => muteCamera = !muteCamera);
  }

  Future<void> _muteAllRemoteVideos() async {
    await _engine.muteAllRemoteVideoStreams(!muteAllRemoteVideo);
    setState(() => muteAllRemoteVideo = !muteAllRemoteVideo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Consultation")),
      body: Stack(
        children: [
          if (_remoteUID != null)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUID),
                  connection: RtcConnection(channelId: _consultController.text),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            width: 120,
            height: 160,
            child: _hasJoined
                ? AgoraVideoView(
  controller: VideoViewController(
    rtcEngine: _engine,
    canvas: const VideoCanvas(uid: 0),
  ),
)

                : Container(
                    color: Colors.black,
                    child: const Center(child: Text("Join a Channel", style: TextStyle(color: Colors.white))),
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _hasJoined ? _leaveChannel : _joinChannel,
                    child: Icon(_hasJoined ? Icons.call_end : Icons.call),
                    backgroundColor: _hasJoined ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(onPressed: _toggleCamera, child: Icon(openCamera ? Icons.videocam : Icons.videocam_off)),
                  const SizedBox(width: 10),
                  FloatingActionButton(onPressed: _muteCameraToggle, child: Icon(muteCamera ? Icons.visibility_off : Icons.visibility)),
                  const SizedBox(width: 10),
                  FloatingActionButton(onPressed: _muteAllRemoteVideos, child: Icon(muteAllRemoteVideo ? Icons.mic_off : Icons.mic)),
                ],
              ),
            ),
          ),
          if (!_hasJoined)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _consultController,
                  decoration: InputDecoration(
                    hintText: "Enter Channel ID",
                    filled: true,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _consultController.clear(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
