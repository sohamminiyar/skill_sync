import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:skillsync/config/appid.dart';
import 'package:skillsync/providers/user_provider.dart';
import 'package:skillsync/resources/firestore_methods.dart';
import 'package:skillsync/pages/home_screen.dart';
import 'package:skillsync/widgets/chat.dart';
import 'package:http/http.dart' as http;

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;

  const BroadcastScreen({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];

  // placeholders (to be implemented later if needed)
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  // --------------------- Agora Init ---------------------
  void _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );

    if (widget.isBroadcaster) {
      await _engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
    } else {
      await _engine.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );
    }

    _joinChannel();
  }

  String baseUrl = "https://skill-sync-server-go-flutter.onrender.com/";

  String? token;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelId +
          '/publisher/userAccount/' +
          Provider.of<UserProvider>(context, listen: false).user.uid +
          '/'),
    );
    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint ('Failed to fetch the token');
    }
  }

  void _addListeners() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
              'joinChannelSuccess ${connection.channelId} ${connection.localUid} $elapsed');
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          debugPrint('userJoined $uid $elapsed');
          setState(() {
            remoteUid.add(uid);
          });
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          debugPrint('userOffline $uid $reason');
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('leaveChannel $stats');
          setState(() {
            remoteUid.clear();
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String expiringToken) {
          getToken().then((_) {
            if (token != null) {
              _engine.renewToken(token!).then((_) {
                debugPrint('Token renewed successfully');
              }).catchError((e) {
                debugPrint('Error renewing token: $e');
              });
            } else {
              debugPrint('Failed to renew token: New token is null');
            }
          }).catchError((e) {
            debugPrint('Error fetching token: $e');
          });
        },
      ),
    );
  }

  void _joinChannel() async {
    await getToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();

      final user = Provider.of<UserProvider>(context, listen: false).user;
      final int agoraUid = user.uid.hashCode & 0x7FFFFFFF;

      await _engine.joinChannel(
        token: token!,
        channelId: widget.channelId,
        uid: agoraUid,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      if (widget.isBroadcaster) {
        await _engine.enableLocalVideo(true);
        await _engine.startPreview();
      }
    }
  }

  Future<void> _leaveChannel() async {
    await _engine.leaveChannel();

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final isOwner = '${user.uid}${user.username}' == widget.channelId;

    if (isOwner) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  // --------------------- Controls (placeholders) ---------------------
  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void _onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  void _startScreenShare() {
    // to be implemented
  }

  void _stopScreenShare() {
    // to be implemented
  }

  // --------------------- UI ---------------------
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _renderVideo(user, isScreenSharing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _switchCamera,
                      child: const Text('Switch Camera'),
                    ),
                    InkWell(
                      onTap: _onToggleMute,
                      child: Text(isMuted ? 'Unmute' : 'Mute'),
                    ),
                  ],
                ),
                Expanded(
                    child: Chat(
                  channelId: widget.channelId,
                ))
                // future controls / chat can go here (like Twitch structure)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderVideo(user, bool isScreenSharing) {
    final isOwner = "${user.uid}${user.username}" == widget.channelId;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isOwner
            // Local view
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            // Remote view
            : remoteUid.isNotEmpty
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: remoteUid[0]),
                      connection: RtcConnection(channelId: widget.channelId),
                    ),
                  )
                // Placeholder
                : Container(color: Colors.black),
      ),
    );
  }
}
