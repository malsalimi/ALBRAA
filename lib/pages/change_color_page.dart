import 'package:flutter/material.dart';

class ChangeColorPage extends StatefulWidget {
  final Function(Color) onColorChanged;

  const ChangeColorPage({super.key, required this.onColorChanged});

  @override
  _ChangeColorPageState createState() => _ChangeColorPageState();
}

class _ChangeColorPageState extends State<ChangeColorPage> {
  Color _selectedColor = Colors.blue;  // اللون الافتراضي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تغيير الألوان"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("اختر اللون المفضل لديك:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.blue;
                    });
                    widget.onColorChanged(Colors.blue);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: _selectedColor == Colors.blue
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.green;
                    });
                    widget.onColorChanged(Colors.green);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: _selectedColor == Colors.green
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.red;
                    });
                    widget.onColorChanged(Colors.red);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: _selectedColor == Colors.red
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
