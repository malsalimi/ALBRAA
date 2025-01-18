import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final File? image;
  final String? displayName;
  final String? email;
  final Function(String) onNameChanged;
  final Function(File?) onImageChanged;

  const ProfilePage({
    super.key,
    required this.image,
    required this.displayName,
    required this.email,
    required this.onNameChanged,
    required this.onImageChanged,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _newImage;

  @override
  void initState() {
    super.initState();
    final displayName = widget.displayName ?? "";
    final names = displayName.split(" ");
    _nameController.text = names.isNotEmpty ? names[0] : "";
    if (names.length > 1) {
      _nameController.text += " ${names[1]}";
    }
    _newImage = widget.image;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
      widget.onImageChanged(
          _newImage); // Notify the parent widget to update the image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الملف الشخصي"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : widget.image != null
                          ? FileImage(widget.image!)
                          : const AssetImage("assets/default_user.png")
                              as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    debugPrint("خطأ في تحميل صورة المستخدم");
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'تغيير الاسم',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 34, 168, 235),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.person,
                          color: Color.fromARGB(255, 54, 177, 238)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 45, 168, 230),
                            width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onNameChanged(
                      _nameController.text); // Notify parent about name change
                  Navigator.pop(context); // العودة بعد تحديث الاسم
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 146, 217),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}