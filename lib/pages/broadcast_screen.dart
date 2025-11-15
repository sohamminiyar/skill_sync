import 'dart:convert';
import 'package:skillsync/models/user.dart' as custom_user;
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

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobileBody;
        }
        return desktopBody;
      },
    );
  }
}

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
  bool isMuted = false;
  bool isScreenSharing = false;
  bool isFrontCamera = true;

  String baseUrl = "https://skill-sync-server-go-flutter.onrender.com";
  String? token;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  // ---------------- Agora Init ----------------
  void _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _addListeners();
    await _engine.enableVideo();

    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    final clientRole = widget.isBroadcaster
        ? ClientRoleType.clientRoleBroadcaster
        : ClientRoleType.clientRoleAudience;
    await _engine.setClientRole(role: clientRole);

    if (widget.isBroadcaster) {
      await _engine.startPreview();
    }

    _joinChannel();
  }

  Future<void> getToken() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final role = widget.isBroadcaster ? 'publisher' : 'subscriber';
    final res = await http.get(
      Uri.parse('$baseUrl/rtc/${widget.channelId}/$role/userAccount/${user.uid}/'),
    );
    if (res.statusCode == 200) {
      setState(() {
        token = jsonDecode(res.body)['rtcToken'];
      });
      debugPrint('Token fetched successfully for role: $role');
    } else {
      debugPrint('Failed to fetch token: ${res.statusCode} - ${res.body}');
    }
  }

  void _addListeners() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('joinChannelSuccess ${connection.channelId} $elapsed');
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          if (!remoteUid.contains(uid)) {
            setState(() {
              remoteUid.add(uid);
            });
          }
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        },
      ),
    );
  }

  void _joinChannel() async {
    await getToken();
    if (token == null) {
      debugPrint('Cannot join: Token is null');
      return;
    }

    if (widget.isBroadcaster) {
      if (kIsWeb) {
        debugPrint('Web: Camera permission handled automatically');
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await [Permission.microphone, Permission.camera].request();
      }
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;

    final channelMediaOptions = ChannelMediaOptions(
      clientRoleType: widget.isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
      publishCameraTrack: widget.isBroadcaster,
      publishMicrophoneTrack: widget.isBroadcaster,
      autoSubscribeAudio: true,
      autoSubscribeVideo: true,
    );

    try {
      await _engine.joinChannelWithUserAccount(
        token: token!,
        channelId: widget.channelId,
        userAccount: user.uid,
        options: channelMediaOptions,
      );
    } catch (e) {
      debugPrint('Error joining channel: $e');
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

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        isFrontCamera = !isFrontCamera;
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ Fix overflow when keyboard opens
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _leaveChannel(),
          ),
          title: const Text(
            'Live Stream',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveLayout(
            desktopBody: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _renderVideo(user),
                      if (widget.isBroadcaster)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildControlButton(
                                icon: Icons.switch_camera,
                                onPressed: isScreenSharing ? null : _switchCamera,
                                tooltip: 'Switch Camera',
                              ),
                              const SizedBox(width: 16),
                              _buildControlButton(
                                icon: isMuted ? Icons.mic_off : Icons.mic,
                                onPressed: _onToggleMute,
                                tooltip: isMuted ? 'Unmute' : 'Mute',
                                isActive: !isMuted,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Chat(channelId: widget.channelId),
                ),
              ],
            ),
            mobileBody: SafeArea( // ✅ Prevents bottom overflow
              child: Column(
                children: [
                  _renderVideo(user),
                  if (widget.isBroadcaster)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.switch_camera,
                            onPressed: isScreenSharing ? null : _switchCamera,
                            tooltip: 'Switch Camera',
                          ),
                          const SizedBox(width: 16),
                          _buildControlButton(
                            icon: isMuted ? Icons.mic_off : Icons.mic,
                            onPressed: _onToggleMute,
                            tooltip: isMuted ? 'Unmute' : 'Mute',
                            isActive: !isMuted,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Chat(channelId: widget.channelId),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: widget.isBroadcaster
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child:kIsWeb
              ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 250),
            child: ElevatedButton(
              onPressed: _leaveChannel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                minimumSize: const Size(120, 48),
              ),
              child: const Text(
                "End Stream",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              : ElevatedButton(
            onPressed: _leaveChannel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              minimumSize: const Size(120, 48),
              maximumSize: const Size(450, 56),
            ),
            child: const Text(
              "End Stream",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        )
            : null,
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isActive = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.deepOrange.shade50 : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: isActive ? Colors.deepOrange : Colors.grey),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _renderVideo(custom_user.User user) {
    final isOwner = '${user.uid}${user.username}' == widget.channelId;

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: isOwner
              ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: VideoCanvas(
                uid: 0,
                sourceType: isScreenSharing
                    ? VideoSourceType.videoSourceScreen
                    : VideoSourceType.videoSourceCamera,
              ),
            ),
          )
              : remoteUid.isNotEmpty
              ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: remoteUid[0]),
              connection: RtcConnection(channelId: widget.channelId),
            ),
          )
              : Container(
            color: Colors.grey.shade100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for stream to start...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _engine.release();
    super.dispose();
  }
}
