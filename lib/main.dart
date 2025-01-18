import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_apk/pages/auth_page.dart';
import 'package:my_flutter_apk/pages/splash_screen.dart'; // استيراد صفحة SplashScreen
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مع الخيارات المناسبة للنظام الأساسي
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تشغيل التطبيق الرئيسي
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, // إعداد اللون الأساسي للتطبيق
      ),
      // تعيين صفحة SplashScreen كصفحة البداية
      home: const SplashScreen(), // يتم عرض صفحة SplashScreen عند بدء التطبيق
    );
  }
}