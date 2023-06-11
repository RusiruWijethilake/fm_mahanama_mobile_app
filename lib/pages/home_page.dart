import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:fm_mahanama_mobile_app/pages/tabs/tab_radio.dart';
import 'package:fm_mahanama_mobile_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FM Mahanama"),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
                  applicationName: "FM Mahanama",
                  applicationVersion: "1.0.0",
                  applicationIcon: const Icon(Icons.radio),
                  applicationLegalese: "© ${DateTime.now().year} FM Mahanama\nDesigned & Developed by Rusiru Wijethilake",
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
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
                            child: const Text("GitHub.com")
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
              const RadioTab(),
              Container(
                child: const Center(
                  child: Text("TV"),
                ),
              ),
              Container(
                child: const Center(
                  child: Text("Scoreboard"),
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
    );
  }

}