import 'package:flutter/material.dart';

class SearchHistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> searchHistory;

  const SearchHistoryPage({super.key, required this.searchHistory});

  @override
  _SearchHistoryPageState createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل البحث"),
      ),
      body: ListView.builder(
        itemCount: widget.searchHistory.length,
        itemBuilder: (context, index) {
          final entry = widget.searchHistory[index];
          return ListTile(
            tileColor: entry['color'],
            title: Text(entry['query']),
            subtitle: Text(entry['timestamp']),
          );
        },
      ),
    );
  }
}
