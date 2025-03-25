import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/sheets_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _sheetsService = SheetsService();
  final _authService = AuthService();
  List<List<Object?>> _searchResults = [];

  Future<void> _performSearch() async {
    final client = await _authService.getAuthenticatedClient();
    if (client == null) return;

    await _sheetsService.init(client);
    // Replace with actual spreadsheet ID and range
    final results = await _sheetsService.searchInSheet(
      'your_spreadsheet_id',
      _searchController.text,
      'Sheet1!A1:Z1000',
    );

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Spreadsheet'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final row = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(row.first.toString()),
                    subtitle: Text(row.skip(1).join(', ')),
                    onTap: () {
                      // Show edit dialog
                      _showEditDialog(row, index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(List<Object?> row, int index) async {
    final controllers = row
        .map((cell) => TextEditingController(text: cell.toString()))
        .toList();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Row'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              controllers.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: 'Column ${i + 1}',
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newValues = controllers.map((c) => c.text).toList();
              // Update the spreadsheet
              await _sheetsService.updateValues(
                'your_spreadsheet_id',
                'Sheet1!A${index + 1}',
                [newValues],
              );
              Navigator.pop(context);
              _performSearch(); // Refresh the results
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}