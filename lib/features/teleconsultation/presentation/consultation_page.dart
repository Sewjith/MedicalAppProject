import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DoctorConsultation extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;

  const DoctorConsultation({
    Key? key,
    required this.appId,
    required this.token,
    required this.channelName,
  }) : super(key: key);

  @override
  State<DoctorConsultation> createState() => _DoctorConsultationState();
}

class _DoctorConsultationState extends State<DoctorConsultation> {
  late final RtcEngine _engine;
  bool _hasJoined = false;
  int? _remoteUID;
  bool _cameraOn = true;
  bool _micOn = true;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _initAgoraEngine();
  }

  @override
  void dispose() {
    _cleanupAgoraEngine();
    super.dispose();
  }

  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _initAgoraEngine() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

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
  }

  Future<void> _joinChannel() async {
    try {
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
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
    });
  }

  void _toggleCamera() {
    setState(() {
      _cameraOn = !_cameraOn;
      _engine.enableLocalVideo(_cameraOn);
    });
  }

  void _toggleMic() {
    setState(() {
      _micOn = !_micOn;
      _engine.muteLocalAudioStream(!_micOn);
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
      _engine.setEnableSpeakerphone(_speakerOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Consultation")),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Remote Video View
                if (_remoteUID != null)
                  Positioned.fill(
                    child: AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine,
                        canvas: VideoCanvas(uid: _remoteUID),
                        connection: RtcConnection(channelId: widget.channelName),
                      ),
                    ),
                  ),

                // Local Video View (Floating)
                Positioned(
                  bottom: 0, // Adjusted so it's above buttons
                  right: 20,
                  width: 120,
                  height: 160,
                  child: _hasJoined
                      ? _cameraOn
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : Container(
                              color: Colors.black,
                              child: const Center(
                                child: Text(
                                  "Video Off",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              "Join a Channel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Control Buttons at the Bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _hasJoined ? _leaveChannel : _joinChannel,
                  child: Icon(_hasJoined ? Icons.call_end : Icons.call),
                  backgroundColor: _hasJoined ? Colors.red : Colors.green,
                ),
                FloatingActionButton(
                  onPressed: _toggleCamera,
                  child: Icon(_cameraOn ? Icons.videocam : Icons.videocam_off),
                ),
                FloatingActionButton(
                  onPressed: _toggleMic,
                  child: Icon(_micOn ? Icons.mic : Icons.mic_off),
                ),
                FloatingActionButton(
                  onPressed: _toggleSpeaker,
                  child: Icon(_speakerOn ? Icons.volume_up : Icons.volume_off),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
