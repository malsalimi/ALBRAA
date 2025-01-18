import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:my_flutter_apk/pages/settings_page.dart';
import 'logs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'login_page.dart';

void main() {
  runApp(const UrlScannerApp());
}

class UrlScannerApp extends StatelessWidget {
  const UrlScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URL Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UrlScannerHomePage(),
    );
  }
}

class UrlScannerHomePage extends StatefulWidget {
  const UrlScannerHomePage({super.key});

  @override
  State<UrlScannerHomePage> createState() => _UrlScannerHomePageState();
}

class _UrlScannerHomePageState extends State<UrlScannerHomePage> {
final user = FirebaseAuth.instance.currentUser!;
  File? _image;
  Color _backgroundColor = Colors.blue; // اللون الافتراضي
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _scanResult;
  bool _isLoading = false;
  String? _scanDuration;
  List<Map<String, String>> _logs = []; // list to hold logs

  var fbm = FirebaseMessaging.instance;
  

  // تحديث الاسم
  void _updateDisplayName(String newName) async {
    try {
      await user.updateDisplayName(newName);
      setState(() {
        user.reload();
      });
      ScaffoldMessenger.of( context).showSnackBar(
        const SnackBar(content: Text("تم تحديث الاسم بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء تحديث الاسم")),
      );
    }
  }

  // تحديث الصورة
  void _updateImage(File? newImage) {
    setState(() {
      _image = newImage;
    });
  }

  // تحديث اللون
  // void _updateBackgroundColor(Color color) {
  //   setState(() {
  //     _backgroundColor = color;
  //   });
  // }
  @override
  void initState() {
    fbm.getToken().then((token) {
      print(token);
    });
    super.initState();
    _loadLogs(); // Load logs when the app starts
  }

  void _deleteScanLog(int index) {
    setState(() {
      _logs.removeAt(index); // إزالة السجل من القائمة
    });
    _saveLogs(); // حفظ التغييرات بعد الحذف
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsData = prefs.getString('logs');
    if (logsData != null) {
      setState(() {
        _logs = List<Map<String, String>>.from(
          json.decode(logsData).map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  // Future<void> _saveLog(Map<String, String> log) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _logs.add(log);
  //   List<String> logsToSave = _logs.map((log) => jsonEncode(log)).toList();
  //   await prefs.setStringList('scan_logs', logsToSave);
  // }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsData = json.encode(_logs);
    await prefs.setString('logs', logsData);
  }

  Future<void> scanUrl(String url) async {
    setState(() {
      _isLoading = true;
      _scanResult = null;
      _scanDuration = null;
    });

    const apiKey =
        '20a99f048ac57248a31e4d3b0a45c9d1ceb91090bbe342b77c668d1bb6fdb82f';
    final apiUrl = Uri.parse('https://www.virustotal.com/api/v3/urls');

    try {
      final startTime = DateTime.now();

      // Encode the URL to base64
      // final urlBytes = utf8.encode(url);
      // final base64Url = base64.encode(urlBytes);

      // Send the scan request
      final response = await http.post(
        apiUrl,
        headers: {
          'x-apikey': apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'url=$url',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final scanId = responseData['data']['id'];

        // Get the scan result
        await Future.delayed(const Duration(seconds: 15)); // Wait for scanning
        final resultResponse = await http.get(
          Uri.parse('https://www.virustotal.com/api/v3/analyses/$scanId'),
          headers: {'x-apikey': apiKey},
        );

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        if (resultResponse.statusCode == 200) {
          final resultData = json.decode(resultResponse.body);
          setState(() {
            _scanResult = resultData['data']['attributes']['stats'];
            _scanDuration =
                '${duration.inSeconds}.${duration.inMilliseconds % 1000} seconds';
          });

          // Save the result to the logs
          final log = {
            'url': url,
            'harmless': _scanResult!['harmless'].toString(),
            'malicious': _scanResult!['malicious'].toString(),
            'suspicious': _scanResult!['suspicious'].toString(),
            'undetected': _scanResult!['undetected'].toString(),
            'scan_duration': _scanDuration!,
            'timestamp': DateTime.now().toString(),
          };

          setState(() {
            _logs.add(log); // Add log to the list
          });

          await _saveLogs(); // Save logs to SharedPreferences
        } else {
          setState(() {
            _scanResult = {
              'error': 'Error fetching scan results. Try again later.'
            };
          });
        }
      } else {
        setState(() {
          _scanResult = {
            'error': 'Failed to scan URL. Check the URL or API key.'
          };
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = {'error': 'An error occurred: $e'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: [
           DrawerHeader(
              decoration: BoxDecoration(
                color: _backgroundColor, // تغيير اللون هنا
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(user.photoURL ?? "assets/default_user.png") as ImageProvider,
                    onBackgroundImageError: (_, __) {
                      debugPrint("خطأ في تحميل صورة المستخدم");
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.displayName ?? "لا يوجد اسم",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user.email ?? "لا يوجد بريد إلكتروني",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("تعديل الملف الشخصي",
              textAlign: TextAlign.right,),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      image: _image,
                      displayName: user.displayName,
                      email: user.email,
                      onNameChanged: _updateDisplayName,
                      onImageChanged: _updateImage,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  "  الاشعارات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsPage(
                            logs: _logs,
                            onDelete: _deleteScanLog,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  "  السجل",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsPage(
                            logs: _logs,
                            onDelete: _deleteScanLog,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  "  الاعدادات ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                    onPressed: () async {
                      final route = MaterialPageRoute(
                          builder: (context) => const SettingsPage());
                      Navigator.push(context, route);
                    },
                    icon: const Icon(Icons.settings)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  " مساعدة ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                    onPressed: () async {}, icon: const Icon(Icons.help)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
              title: const Text(
                " تسجيل الخروج ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        "LoginPage", (route) => false);
                  },
                  icon: const Icon(Icons.exit_to_app)),
            ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  " حول التطبيق ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              title: Text("مرحبا"),
                              content: Text("تطبيق مكافح الروابط الضارة"),
                            );
                          });
                    },
                    icon: const Icon(Icons.help)),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 51, 87),
        foregroundColor: const Color.fromARGB(255, 246, 249, 251),
        title: const Text('Malicious URL Scanner'),
        actions: const [
          // IconButton(
          //   icon: const Icon(Icons.history),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => LogsPage(
          //           logs: _logs,
          //           onDelete: _deleteScanLog,
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan any URL to check for malicious activity:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        final url = _urlController.text.trim();
                        if (url.isNotEmpty) {
                          scanUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid URL.'),
                            ),
                          );
                        }
                      },
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.search),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Scan URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 3, 51, 87),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_scanDuration != null)
              Text(
                'Scan Time: $_scanDuration',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            const SizedBox(height: 16),
            if (_scanResult != null)
              Expanded(
                child: SingleChildScrollView(
                  child: _scanResult!.containsKey('error')
                      ? Center(
                          child: Text(
                            _scanResult!['error'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan Results:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent.shade700,
                                  ),
                                ),
                                const Divider(thickness: 1),
                                buildResultRow('Harmless', Colors.green,
                                    _scanResult!['harmless']),
                                buildResultRow('Malicious', Colors.red,
                                    _scanResult!['malicious']),
                                buildResultRow('Suspicious', Colors.orange,
                                    _scanResult!['suspicious']),
                                buildResultRow('Undetected', Colors.grey,
                                    _scanResult!['undetected']),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildResultRow(String label, Color color, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
