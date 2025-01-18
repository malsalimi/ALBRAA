import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showChangePasswordDialog(); // استدعاء الرسالة المنبثقة عند فتح الصفحة
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );

        // إعادة المصادقة
        await user.reauthenticateWithCredential(credential);

        // التحقق من أن كلمة المرور الجديدة لا تطابق القديمة
        if (_oldPasswordController.text == _newPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('كلمة المرور الجديدة لا يمكن أن تكون مطابقة للقديمة.'),
            ),
          );
          return; // إيقاف العملية إذا كانت الكلمتان متطابقتين
        }

        // التحقق من تطابق كلمة المرور الجديدة مع التأكيد
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw Exception("كلمة المرور الجديدة وإعادة الإدخال غير متطابقتين.");
        }

        // تحديث كلمة المرور
        await user.updatePassword(_newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح!')),
        );
        Navigator.pop(context); // إغلاق النافذة المنبثقة
      } else {
        throw Exception("المستخدم غير مسجل الدخول.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // يمنع إغلاق النافذة بالنقر خارجها
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تغيير كلمة المرور"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: "كلمة المرور القديمة",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور القديمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: "كلمة المرور الجديدة",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الجديدة';
                      }
                      if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: "إعادة إدخال كلمة المرور الجديدة",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إعادة إدخال كلمة المرور الجديدة';
                      }
                      if (value != _newPasswordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // إغلاق النافذة
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
