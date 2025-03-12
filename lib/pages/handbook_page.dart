import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class HandbookPage extends StatefulWidget {
  const HandbookPage({super.key});

  @override
  State<HandbookPage> createState() => _HandbookPageState();
}

class _HandbookPageState extends State<HandbookPage> {
  List<dynamic> serviceHistoryList = [];
  bool isLoading = true;
  String errorMessage = '';
  String bikeName = '';
  String fin = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getBikeInfoAndFetchServices();
  }

  void getBikeInfoAndFetchServices() {
    final user = Provider.of<UserModel>(context, listen: false);

    if (user.bikes != null && user.bikes!.isNotEmpty) {
      final bike = user.bikes!.first;
      bikeName = bike.model;
      fin = bike.fin;

      fetchServiceHistory();
    } else {
      setState(() {
        errorMessage = 'Kein Bike gefunden';
        isLoading = false;
      });
    }
  }

  Future<void> fetchServiceHistory() async {
    final url =
        'https://it200287.cloud.htl-leonding.ac.at/api/maintenance/getBikeserviceHistory/fin/$fin';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('getByFinDTOList')) {
          bikeName = jsonResponse['bike']?['model'] ?? bikeName;

          List<dynamic> historyList = jsonResponse['getByFinDTOList'];

          // ✅ Sort by serviceDate DESCENDING (newest first)
          historyList.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['serviceDate'] ?? '') ?? DateTime(1970);
            DateTime dateB = DateTime.tryParse(b['serviceDate'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

          setState(() {
            serviceHistoryList = historyList;
            isLoading = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            errorMessage = 'Fehler: Unerwartete Datenstruktur';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Fehler beim Laden: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Ein Fehler ist aufgetreten: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bikeName.isNotEmpty ? bikeName : 'Handbuch'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : serviceHistoryList.isEmpty
          ? const Center(
        child: Text('Keine Service-Historie gefunden.'),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await fetchServiceHistory();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: serviceHistoryList.length,
            itemBuilder: (context, index) {
              final service = serviceHistoryList[index];

              String rawDate = service['serviceDate'] ?? '';
              String formattedDate = rawDate.isNotEmpty
                  ? DateFormat('dd-MM-yy')
                  .format(DateTime.parse(rawDate))
                  : 'Kein Datum';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(
                            Icons.build_circle_outlined),
                        title: Text(
                          service['bikeService']?['title'] ??
                              'Kein Titel vorhanden',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Kilometerstand beim Service: ${service['kilometersAtService'] ?? 'Unbekannt'} km',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Erstellt am: ${service['createdAt'] ?? 'Unbekannt'}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
