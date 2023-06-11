import 'package:assets_audio_player/src/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fm_mahanama_mobile_app/pages/tabs/chat_view.dart';
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _radioStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData && !snapshot.data!.exists) {
              return const Text("Document does not exist");
            }
            if (snapshot.data!.get("onair") == true) {
              String nowPlaying = snapshot.data!.get("nowplaying");
              String by = snapshot.data!.get("by");
              String coverPhoto = snapshot.data!.get("cover");
              final gsCoverPhoto = FirebaseStorage.instance.refFromURL(coverPhoto);

              return Column(
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
                      child: StreamBuilder(
                        stream: gsCoverPhoto.getDownloadURL().asStream(),
                        builder: (context, snapshot) {
                          return Image.network(
                            snapshot.data.toString(),
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
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Text(
                      "Music Infinity",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Text(
                      "Mahanama College Radio Club",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        controller.isCompleted ? controller.reverse() : controller.forward();
                      });
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
                  ),
                  const SizedBox(height: 22.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 70,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, ChatPage.routeName);
                          },
                          icon: const Icon(Icons.chat_rounded),
                          iconSize: 24.0,
                          color: Colors.black54,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded),
                          iconSize: 24.0,
                          color: Colors.black54,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.heart),
                          iconSize: 24.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              widget.radioPlayer.stop();

              return Container(
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
                      Text(
                        "FM Mahanama is currently offline!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
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
                            label: Text("Facebook"),
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
                            label: Text("Instagram"),
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
              );
            }
          },
        ),
      ),
    );
  }

}