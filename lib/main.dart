import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CreditCardApp());
}

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Data Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CardListScreen(),
    );
  }
}

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  Future<void> _fetchCardData() async {
    try {
      // Fetches from the static asset path relative to the web root
      final response = await http.get(Uri.parse('api/list-cc.json'));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalInfo = _data?['personal_info'] as Map<String, dynamic>?;
    final cards = _data?['cards'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Data Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      if (personalInfo != null) ...[
                        Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Divider(),
                                Text('Name: ${personalInfo['full_name']}'),
                                Text('Address: ${personalInfo['street_address']}, ${personalInfo['city']}, ${personalInfo['state']} ${personalInfo['postal_code']}'),
                                Text('Country: ${personalInfo['country']}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const Text(
                        'Cards List',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Cards List Section
                      if (cards != null)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.credit_card,
                                    color: Colors.indigo),
                                title: Text(
                                  '${card['number']} (${card['type']})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Issuer: ${card['issuer']} | Expires: ${card['exp_month']}/${card['exp_year']} | CVV: ${card['cvv']}',
                                ),
                                trailing: Text(card['country'],
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
