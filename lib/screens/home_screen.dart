import 'dart:convert';

import 'package:demo/models/lead_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Lead>> futureLeads;
  List<Lead> allLeads = [];
  List<Lead> filteredLeads = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  static const String apiUrl = 'https://api.thenotary.app/lead/getLeads';

  Future<List<Lead>> fetchData() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'notaryId': '6668baaed6a4670012a6e406',
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null &&
          jsonResponse is Map<String, dynamic> &&
          jsonResponse['leads'] != null) {
        List<Lead> leads = (jsonResponse['leads'] as List)
            .map((data) => Lead.fromJson(data))
            .toList();
        return leads;
      } else {
        throw Exception('Leads not found in the response');
      }
    } else {
      throw Exception('Failed to load leads');
    }
  }

  @override
  void initState() {
    super.initState();
    futureLeads = fetchData();
    futureLeads.then((leads) {
      setState(() {
        allLeads = leads;
        filteredLeads = leads;
      });
    });
  }

  void filterLeads(String query) {
    List<Lead> results = [];
    if (query.isEmpty) {
      results = allLeads;
    } else {
      results = allLeads
          .where(
              (lead) => lead.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredLeads = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? const Text('Leads')
            : TextField(
                controller: searchController,
                onChanged: filterLeads,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search leads',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
        actions: [
          isSearching
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      filteredLeads = allLeads;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
        ],
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Lead>>(
        future: futureLeads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leads found'));
          } else {
            return ListView.builder(
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                Lead lead = filteredLeads[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(lead.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead.email),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
