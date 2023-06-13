import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fm_mahanama_mobile_app/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RadioTab extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final AssetsAudioPlayer radioPlayer;

  const RadioTab({Key? key, required this.radioPlayer, required this.analytics}) : super(key: key);

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> with SingleTickerProviderStateMixin {

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _radioStream = FirebaseFirestore.instance.collection('public').doc('stream').snapshots();

  late AnimationController controller;
  late Animation<double> animation;

  bool _initialLoad = false;
  bool _streamOnline = false;

  String _nowPlaying = "";
  String _by = "";
  String _coverPhoto = "";
  String _radioStreamUrl = "";

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    loadAndListenToRadioData();
  }

  void loadAndListenToRadioData() async {
    _radioStream.listen((event) {
      if (event.exists) {
        bool onAir = event.get("onair");
        String nowPlaying = event.get("nowplaying");
        String by = event.get("by");
        String radioStreamUrl = event.get("link");
        String coverPhoto = event.get("cover");

        if (onAir != _streamOnline) {
          setState(() {
            _streamOnline = onAir;
          });
        }

        if (nowPlaying != _nowPlaying) {
          setState(() {
            _nowPlaying = nowPlaying;
          });
        }

        if (by != _by) {
          setState(() {
            _by = by;
          });
        }

        if (radioStreamUrl != _radioStreamUrl) {
          setState(() {
            _radioStreamUrl = radioStreamUrl;
          });
        }

        FirebaseStorage.instance.refFromURL(coverPhoto).getDownloadURL().then((value) {
          if (value != _coverPhoto) {
            setState(() {
              _coverPhoto = value;
            });
            if (_streamOnline) {
              widget.radioPlayer.open(
                Audio.liveStream(
                  radioStreamUrl,
                  metas: Metas(
                    title: nowPlaying,
                    artist: by,
                    image: MetasImage.network(coverPhoto),
                  ),
                ),
                autoStart: false,
                notificationSettings: const NotificationSettings(
                  nextEnabled: false,
                  prevEnabled: false,
                  seekBarEnabled: false,
                  playPauseEnabled: true,
                  stopEnabled: false,
                ),
                forceOpen: true,
                playInBackground: PlayInBackground.enabled,
                audioFocusStrategy: const AudioFocusStrategy.request(
                  resumeAfterInterruption: true,
                  resumeOthersPlayersAfterDone: true,
                ),
                showNotification: true,
              );
            }
          }
        });
      }
      _initialLoad = true;
    });
  }

  @override
  void dispose() {
    widget.radioPlayer.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: _initialLoad ? _streamOnline ? Column(
          children: [
            const Text(
              "NOW PLAYING",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 22.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.62,
              height: MediaQuery.of(context).size.width * 0.62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(240.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 4.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(240.0),
                child: Image.network(
                  _coverPhoto,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(color: AppColors().appColorYellow,),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error_outline_rounded, color: Colors.grey, size: 48.0,),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22.0),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text(
                _nowPlaying,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text(
                _by,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 22.0),
            widget.radioPlayer.builderIsPlaying(builder: (context, isPlaying) {
              if (isPlaying) {
                controller.forward();
              } else {
                controller.reverse();
              }

              return IconButton.filled(
                onPressed: () async {
                  if (isPlaying) {
                    await widget.analytics.logEvent(name: 'radio_stop', parameters: null);
                    widget.radioPlayer.stop();
                    controller.reverse();
                    widget.radioPlayer.updateCurrentAudioNotification(
                      metas: Metas(
                        title: _nowPlaying,
                        artist: _by,
                        image: MetasImage.network(_coverPhoto),
                      ),
                      showNotifications: false,
                    );
                    widget.analytics.logEvent(name: 'radio_stop', parameters: null);
                  } else {
                    widget.radioPlayer.play();
                    widget.radioPlayer.setLoopMode(LoopMode.none);
                    controller.forward();
                    widget.radioPlayer.updateCurrentAudioNotification(
                      metas: Metas(
                        title: _nowPlaying,
                        artist: _by,
                        image: MetasImage.network(_coverPhoto),
                      ),
                      showNotifications: true,
                    );
                    widget.analytics.logEvent(name: 'radio_play', parameters: null);
                  }
                },
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: animation,
                  size: 52.0,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.all(18.0),
                ),
              );
            },),
            const SizedBox(height: 22.0),
            widget.radioPlayer.builderIsBuffering(
              builder: (context, isBuffering) {
                if (isBuffering) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.black.withOpacity(0.1),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 22.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 70,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded),
                    iconSize: 24.0,
                    color: Colors.black87,
                    tooltip: "Share the live radio",
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.heart),
                    iconSize: 24.0,
                    color: Colors.black87,
                    tooltip: "Like the stream",
                  ),
                ],
              ),
            ),
          ],
        ) : Container(
          height: MediaQuery.of(context).size.width * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16.0,
                offset: const Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "FM Mahanama is currently offline!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Please check back later or check our social media for updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(FontAwesomeIcons.facebookF),
                      label: const Text("Facebook"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(FontAwesomeIcons.instagram),
                      label: const Text("Instagram"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) : const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}