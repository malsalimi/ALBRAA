import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_flutter_apk/pages/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onPressed;
  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// ClipPath لتصميم الشكل العلوي
class DrawClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.1, size.height - 50);
    path.lineTo(size.width * 0.9, size.height - 50);
    path.lineTo(size.width, size.height - 100);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // تنظيف الموارد عند إلغاء التخصيص
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // إرسال رابط استعادة كلمة المرور
  sendPasswordResetEmail() async {
    try {
      if (_email.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء إدخال البريد الإلكتروني')),
        );
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        default:
          errorMessage = e.message ?? 'حدث خطأ أثناء إرسال رابط الاستعادة';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/UrlScannerApp');
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = '';
      switch (e.code) {
        case 'invalid-email':
          errorMessage =
              'البريد الإلكتروني الذي أدخلته غير صحيح. يرجى التأكد وإعادة المحاولة.';
          break;
        case 'user-not-found':
          errorMessage = 'لم يتم العثور على حساب مرتبط بهذا البريد الإلكتروني.';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور التي أدخلتها غير صحيحة. حاول مرة أخرى.';
          break;
        case 'user-disabled':
          errorMessage =
              'تم تعطيل الحساب الخاص بك. يرجى التواصل مع الدعم الفني.';
          break;
        case 'too-many-requests':
          errorMessage =
              'تم حظر المحاولة بسبب عدد كبير من الطلبات. يرجى المحاولة لاحقاً.';
          break;
        case 'network-request-failed':
          errorMessage =
              'حدث خطأ في الشبكة. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.';
          break;
        default:
          errorMessage =
              e.message ?? 'حدث خطأ غير معروف. يرجى المحاولة لاحقاً.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // تسجيل الدخول باستخدام Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      GoogleSignInAccount? googleUser = googleSignIn.currentUser;

      if (googleUser == null) {
        googleUser = await googleSignIn.signIn();
      }

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تسجيل الدخول باستخدام Google بنجاح'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacementNamed(context, '/UrlScannerApp');
      }

      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // عرض رسالة خطأ باستخدام SnackBar
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // إضافة التصميم الخاص بالخلفية العلوية
            Stack(
              children: [
                ClipPath(
                  clipper: DrawClip(),
                  child: Container(
                    height: size.height / 2.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff1e3c72), // أزرق داكن (كحلي غامق)
                          Color(0xff2a5298), // أزرق متوسط (كحلي فاتح)
                          Color(0xff4a90e2), // أزرق فاتح (لمسة فاتحة)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height / 10,
                  left: size.width / 4,
                  child: Image.asset(
                    'assets/images/malware5.png', //,
                    width: size.width / 2,
                    height: size.height / 6,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الحقول النصية
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _email,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "البريد الإلكتروني",
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _password,
                        obscureText: true,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "كلمة المرور",
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
// زر تسجيل الدخول
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff6a11cb), // بنفسجي غامق
                              Color(0xff2575fc), // أزرق فاتح
                              Color(0xff00c6ff), // أزرق سماوي
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(12), // زوايا دائرية
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signInWithEmailAndPassword();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // جعل الخلفية شفافة
                            shadowColor: Colors.transparent, // إزالة الظل
                            minimumSize:
                                const Size(double.infinity, 60), // حجم الزر
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // زوايا دائرية
                            ),
                            padding: EdgeInsets.zero, // إزالة الحشو الداخلي
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white, // لون النص
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(), // مساحة فارغة على اليسار
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20), // إزاحة 20 بكسل من الجانب الأيمن
                          child: GestureDetector(
                            onTap: sendPasswordResetEmail, // إضافة تفاعل النقر
                            child: const Text(
                              "نسيت كلمة المرور ؟",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                color: Color.fromARGB(255, 242, 33, 33),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
// زر إنشاء حساب
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff6a11cb), // بنفسجي غامق
                              Color(0xff2575fc), // أزرق فاتح
                              Color(0xff00c6ff), // أزرق سماوي
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(12), // زوايا دائرية
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onPressed ??
                              () {
                                Navigator.pushNamed(context, '/UrlScannerApp');
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // جعل الخلفية شفافة
                            shadowColor: Colors.transparent, // إزالة الظل
                            minimumSize:
                                const Size(double.infinity, 60), // حجم الزر
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // زوايا دائرية
                            ),
                            padding: EdgeInsets.zero, // إزالة الحشو الداخلي
                          ),
                          child: const Text(
                            "إنشاء حساب",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white, // لون النص
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // تسجيل الدخول باستخدام Google
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // توسيط العناصر
                        children: [
                          // أيقونة Google
                          InkWell(
                            onTap: () {
                              signInWithGoogle();
                            },
                            child: Image.asset(
                              'assets/icons/google.png',
                              width: 48, // حجم الأيقونة
                              height: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
