import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_apk/pages/login_or_signup.dart';
import 'package:my_flutter_apk/pages/login_page.dart';

// صفحة إنشاء حساب
class SignUp extends StatefulWidget {
  final void Function() onPressed;
  const SignUp({super.key, required this.onPressed});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool isloading = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  createUserWithEmailAndPassword() async {
    if (_password.text != _confirmPassword.text) {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمات المرور غير متطابقة."),
        ),
      );
    }

    try {
      setState(() {
        isloading = true;
      });

      // إنشاء الحساب
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      // تحديث الاسم الأول والاسم الأخير في displayName
      await userCredential.user!.updateDisplayName("${_firstName.text} ${_lastName.text}");

      setState(() {
        isloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إنشاء الحساب بنجاح."),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });
      if (e.code == 'weak-password') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("كلمة المرور ضعيفة للغاية."),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("البريد الإلكتروني مستخدم بالفعل."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 249, 251),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginAndSignUp()),
            ); // العودة إلى الصفحة السابقة
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // التصميم العلوي مع ClipPath
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
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _firstName,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'يرجى إدخال اسمك الأول';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "الاسم الأول",
                          prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _lastName,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'يرجى إدخال اسمك الأخير';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "الاسم الأخير",
                          prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: _email,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'يرجى إدخال بريدك الإلكتروني';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "البريد الإلكتروني",
                          prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  const SizedBox(height: 10),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  child: TextFormField(
    controller: _password,
    obscureText: true,
    validator: (text) {
      if (text == null || text.isEmpty) {
        return 'يرجى إدخال كلمة المرور';
      }
      return null;
    },
    decoration: InputDecoration(
      hintText: "كلمة المرور",
      prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  ),
),
const SizedBox(height: 10),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  child: TextFormField(
    controller: _confirmPassword,
    obscureText: true,
    validator: (text) {
      if (text == null || text != _password.text) {
        return 'كلمات المرور غير متطابقة';
      }
      return null;
    },
    decoration: InputDecoration(
      hintText: "تأكيد كلمة المرور",
      prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  ),
),
const SizedBox(height: 10),
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
      borderRadius: BorderRadius.circular(12), // زوايا دائرية
    ),
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          createUserWithEmailAndPassword();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // جعل الخلفية شفافة
        shadowColor: Colors.transparent, // إزالة الظل
        minimumSize: const Size(double.infinity, 50), // حجم الزر
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // زوايا دائرية
        ),
        padding: EdgeInsets.zero, // إزالة الحشو الداخلي
      ),
      child: isloading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "إنشاء حساب",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // لون النص
              ),
            ),
    ),
  ),
),
const SizedBox(height: 10),
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
      borderRadius: BorderRadius.circular(12), // زوايا دائرية
    ),
    child: ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // جعل الخلفية شفافة
        shadowColor: Colors.transparent, // إزالة الظل
        minimumSize: const Size(double.infinity, 50), // حجم الزر
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // زوايا دائرية
        ),
        padding: EdgeInsets.zero, // إزالة الحشو الداخلي
      ),
      child: const Text(
        "تسجيل الدخول",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // لون النص
        ),
      ),
    ),
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
