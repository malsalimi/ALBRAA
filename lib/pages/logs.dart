import 'package:flutter/material.dart';
import 'Search.dart';
import 'auth_page.dart';
import 'login_page.dart';

class LogsPage extends StatelessWidget {
  final List<Map<String, String>> logs;
  final Function(int) onDelete;

  const LogsPage({super.key, required this.logs, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Logs'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('URL: ${log['url']}'),
              subtitle: Text(
                'Harmless: ${log['harmless']}\n'
                'Malicious: ${log['malicious']}\n'
                'suspicious: ${log['suspicious']}\n'
                'undetected: ${log['undetected']}\n'
                'Timestamp: ${log['timestamp']}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(index), // استدعاء دالة الحذف
              ),
            ),
          );
        },
      ),
    );
  }
}
