import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'auth_page.dart'; // استيراد صفحة تسجيل الدخول

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // إعداد الفيديو
    _videoController = VideoPlayerController.asset(
      'assets/videos/ahmed.mp4', // ضع مسار الفيديو هنا
    )
      ..initialize().then((_) {
        setState(() {}); // لإعادة بناء الواجهة عند الانتهاء من التحميل
        _videoController.play(); // تشغيل الفيديو تلقائيًا
        _videoController.setLooping(true); // تشغيل الفيديو بشكل متكرر
      });

    // الانتقال إلى صفحة تسجيل الدخول بعد انتهاء الفيديو
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
            : Container(), // إخفاء مؤشر التحميل
      ),
    );
  }
}