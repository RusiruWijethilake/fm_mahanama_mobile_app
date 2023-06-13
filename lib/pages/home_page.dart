import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fm_mahanama_mobile_app/pages/chat_page.dart';
import 'package:fm_mahanama_mobile_app/pages/tabs/tab_radio.dart';
import 'package:fm_mahanama_mobile_app/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  FirebaseAnalytics analytics;
  AssetsAudioPlayer radioPlayer;
  PackageInfo packageInfo;

  HomePage({Key? key, required this.analytics, required this.radioPlayer, required this.packageInfo}) : super(key: key);

  static const String routeName = '/home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _radioStream = FirebaseFirestore.instance.collection('public').doc('stream').snapshots();

  int _selectedIndex = 0;
  bool _chatEnabled = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    checkAndListenToFirestoreState();
    widget.analytics.setCurrentScreen(screenName: HomePage.routeName);
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FM Mahanama"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: "More options",
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: "settings",
                  child: Text("Settings"),
                ),
                const PopupMenuItem(
                  value: "about",
                  child: Text("About"),
                ),
              ];
            },
            onSelected: (value) {
              if (value == "about") {
                showAboutDialog(
                  context: context,
                  applicationName: widget.packageInfo.appName,
                  applicationVersion: widget.packageInfo.version,
                  applicationIcon: Image.asset("assets/icons/ic_logo_border.png", width: 100, height: 120, fit: BoxFit.contain,),
                  applicationLegalese: "© ${DateTime.now().year} FM Mahanama",
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Designed & Developed by Rusiru Wijethilake", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text("FM Mahanama is the official radio station of Mahanama College Radio Club."),
                          const SizedBox(height: 12),
                          const Text("This app is open-sourced and available on GitHub under the MIT License. Checkout the source code at following locations."),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              String gitUrl = "https://github.com/RusiruWijethilake/fm_mahanama_mobile_app.git";
                              try {
                                await launchUrlString(gitUrl);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Can't launch the URL. Access the source code at $gitUrl"),
                                  ),
                                );
                              }
                            },
                            child: const Text("📎 GitHub.com", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ]
                );
              } else if (value == "settings") {
                // Navigator.pushNamed(context, AboutPage.routeName);
              }
            },
          )
        ],
      ),
      backgroundColor: AppColors().appColorYellow,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: GradientColors.yellow,
                begin: Alignment.bottomCenter,
                end: Alignment.topLeft,
              ),
            ),
          ),

          SafeArea(
            child: IndexedStack(
            index: _selectedIndex,
            children: [
              RadioTab(analytics: widget.analytics, radioPlayer: widget.radioPlayer),
              Container(
                child: const Center(
                  child: Text("TV Page Under Development"),
                ),
              ),
              Container(
                child: const Center(
                  child: Text("Scoreboard Page Under Development"),
                ),
              ),
            ],
          ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radio_rounded),
            label: 'Radio',
            tooltip: 'Listen to FM Mahanama live stream',
          ),
          NavigationDestination(
            icon: Icon(Icons.tv_rounded),
            label: 'TV',
            tooltip: 'Watch TV Mahanama live',
          ),
          NavigationDestination(
            icon: Icon(Icons.scoreboard_rounded),
            label: 'Scoreboard',
            tooltip: 'Scoreboard for live matches',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_chatEnabled) {
            Navigator.pushNamed(context, ChatPage.routeName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Chat is disabled by the admin! Please try again later."),
              ),
            );
          }
        },
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }

  void checkAndListenToFirestoreState() async {
    _radioStream.listen((event) {
      if (event.exists) {
        bool chatEnabled = event.data()!['chat_enabled'];

        if (chatEnabled) {
          setState(() {
            _chatEnabled = true;
          });
        } else {
          setState(() {
            _chatEnabled = false;
          });
        }
      }
    });
  }

}