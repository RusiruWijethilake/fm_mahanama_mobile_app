import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:fm_mahanama_mobile_app/theme/app_colors.dart';
import 'package:fm_mahanama_mobile_app/values/custom_profanity_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';

class ChatPage extends StatefulWidget {
  FirebaseAnalytics analytics;

  ChatPage({Key? key, required this.analytics}) : super(key: key);

  static const String routeName = '/chat_view';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfanityFilter _profanityFilter = ProfanityFilter.filterAdditionally(
      CustomProfanityList().getCustomProfanityList());

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    widget.analytics.setCurrentScreen(screenName: ChatPage.routeName);
    widget.analytics.logEvent(name: 'chat_page_opened');
  }

  void _loadChatHistory() {
    _firestore
        .collection('global_chat')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _messages = querySnapshot.docs
            .map<Map<String, dynamic>>(
                (doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    });
  }

  void _sendMessage() {
    final user = _auth.currentUser;
    if (user != null) {
      final messageText = _messageController.text;

      // Check if the message contains bad words
      if (_profanityFilter.hasProfanity(messageText)) {
        // Replace bad words with "*"
        final filteredMessage = _profanityFilter.censor(messageText);

        final newMessage = {
          'author': user.displayName,
          'authorId': user.uid,
          'authorPhotoUrl': user.photoURL,
          'message': filteredMessage,
          'timestamp': DateTime.now(),
        };
        _firestore.collection('global_chat').add(newMessage);
        _messageController.clear();
      } else {
        // Message is clean, send as is
        final newMessage = {
          'author': user.displayName,
          'authorId': user.uid,
          'authorPhotoUrl': user.photoURL,
          'message': messageText,
          'timestamp': DateTime.now(),
        };
        _firestore.collection('global_chat').add(newMessage);
        _messageController.clear();
      }
    }
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    String chatMessgae = _profanityFilter.censor(message["message"]);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _auth.currentUser?.uid == message['authorId']
            ? Colors.white
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(message['authorPhotoUrl']),
        ),
        title: Text(chatMessgae,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400)),
        subtitle: Row(
          children: [
            Text(message['author'], style: const TextStyle(fontSize: 10.0)),
            const SizedBox(width: 12.0),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.clock,
                  size: 12.0,
                  color: Colors.grey,
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatFirebaseTimestamp(message['timestamp']),
                  style: const TextStyle(fontSize: 10.0),
                ),
              ],
            )
          ],
        ),
        trailing: _auth.currentUser!.uid != message['authorId']
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Report'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportMessage(message, _auth.currentUser!.uid);
                  }
                },
              )
            : null,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: 16.0,
        contentPadding: const EdgeInsets.all(4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Chat'),
        backgroundColor: Colors.white.withOpacity(0.8),
        surfaceTintColor: Colors.white.withOpacity(0.0),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      backgroundColor: AppColors().appColorYellow,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: GradientColors.yellow,
                begin: Alignment.bottomLeft,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
              maintainBottomViewPadding: true,
              child: StreamBuilder(
                stream: _auth.authStateChanges().asBroadcastStream(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        height: MediaQuery.of(context).size.width * 0.8,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Welcome to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              const Text(
                                "FM Mahanama",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              const Text(
                                "Global Chat!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              const Text(
                                'You need to be signed in to use the chat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    await signInWithGoogle();
                                    widget.analytics.logEvent(
                                      name: 'joined_chat',
                                      parameters: {
                                        'user': _auth.currentUser!.uid,
                                        'timestamp': DateTime.now(),
                                      },
                                    );
                                    _showWarningMessage();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Error signing in with Google! Please try again later."),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(FontAwesomeIcons.google),
                                label: const Text('Sign in with Google'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data!.photoURL!),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Logged in as ${snapshot.data!.displayName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!.email}',
                                  ),
                                ],
                              ),
                              IconButton.filledTonal(
                                onPressed: () {
                                  GoogleSignIn().disconnect();
                                  _auth.signOut();
                                },
                                icon: const Icon(Icons.logout),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('global_chat')
                                .orderBy('timestamp', descending: true)
                                .limit(20)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('No data available');
                              }
                              final messages = snapshot.data!.docs;

                              return ListView.separated(
                                reverse: true,
                                controller: _scrollController,
                                itemCount: messages.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(height: 8.0);
                                },
                                padding: const EdgeInsets.all(8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final Map<String, dynamic> message =
                                      messages[index].data()
                                          as Map<String, dynamic>;
                                  message.addAll({
                                    'id': messages[index].id,
                                  });
                                  return _buildChatMessage(message);
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Type your message...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.text,
                                  maxLength: 300,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  enableIMEPersonalizedLearning: true,
                                  buildCounter: (BuildContext context,
                                          {int? currentLength,
                                          int? maxLength,
                                          bool? isFocused}) =>
                                      null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded),
                                onPressed: _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              )),
        ],
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  String formatFirebaseTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedDateTime = dateFormat.format(dateTime);
    return formattedDateTime;
  }

  void _showWarningMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded),
          title: const Text('Be Respectful!'),
          content: const Text(
              'This is a global chat. Please be respectful to others and do not post anything inappropriate. If we find any inappropriate messages, we will ban you from using the chat. Chat will be resetted every week to keep it clean.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Got It!'),
            ),
          ],
        );
      },
    );
  }

  void _showReportMessage(Map<String, dynamic> message, String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded),
          title: const Text('Report Message'),
          content: const Text(
              'Are you sure you want to report this message? This will be reviewed by the admins and if found inappropriate, the user will be banned from using the chat.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('global_chat_reports').add({
                  'message': message,
                  'timestamp': Timestamp.now(),
                  'reported by': uid,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }
}
