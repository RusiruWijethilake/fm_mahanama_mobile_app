import 'package:flutter/material.dart';
import 'package:fm_mahanama_mobile_app/theme/app_colors.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({Key? key}) : super(key: key);

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> with SingleTickerProviderStateMixin {

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
        child: Column(
          children: [
            const Text(
              "NOW PLAYING",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 24.0),
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
                  "https://firebasestorage.googleapis.com/v0/b/fm-mahanama-2017-live-stream.appspot.com/o/cover_photos%2FRadio%20Club%20CC.jpg?alt=media&token=9ceec846-30b0-4ebb-90c9-02d6c92bf1e4",
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
            const SizedBox(height: 32.0),
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
            const SizedBox(height: 32.0),
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
                backgroundColor: Theme.of(context).colorScheme.background,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.all(18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}