import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/user_model.dart';

class BikeDetailPage extends StatefulWidget {
  const BikeDetailPage({super.key});

  @override
  State<BikeDetailPage> createState() => _BikeDetailPageState();
}

class _BikeDetailPageState extends State<BikeDetailPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> services = [];
  List<int> fadingOutIndexes = [];

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    final user = Provider.of<UserModel>(context, listen: false);

    if (user.bikes == null || user.bikes!.isEmpty) {
      setState(() {
        errorMessage = 'No bikes available. Please add a bike.';
        isLoading = false;
      });
      return;
    }

    final selectedBike = user.bikes!.first;
    final url =
        '${Config.baseUrl}maintenance/getServicesByBike/${selectedBike.id}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          services = data['services'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load services: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> markServiceCompleted({
    required int serviceId,
    required String fin,
    required String email,
    required int km,
    required int index,
  }) async {
    final url = '${Config.baseUrl}maintenance/addServiceHistory';
    final requestBody = {
      'email': email,
      'fin': fin,
      'serviceId': serviceId,
      'km': km,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response from server: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final updatedNextServiceKm = responseBody ?? null;

        if (updatedNextServiceKm != null) {
          setState(() {
            services[index]['nextServiceKm'] = updatedNextServiceKm;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service marked as completed!')),
        );

        setState(() {
          fadingOutIndexes.add(index);
        });

        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          fadingOutIndexes.remove(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to mark service: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _showConfirmationDialog({
    required int serviceId,
    required String fin,
    required String email,
    required int km,
    required int index,
    required int bikeId,
  }) {
    final TextEditingController kmController =
    TextEditingController(text: km.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Completion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you have completed this service?'),
              const SizedBox(height: 16),
              TextField(
                controller: kmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Aktueller Kilometerstand',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final int enteredKm = int.tryParse(kmController.text) ?? km;

                Provider.of<UserModel>(context, listen: false).updateBikeKm(
                  bikeId,
                  enteredKm,
                );

                Navigator.of(context).pop();

                markServiceCompleted(
                  serviceId: serviceId,
                  fin: fin,
                  email: email,
                  km: enteredKm,
                  index: index,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchGuidance(int guidanceId) async {
    final url =
        'https://strapi-production-23a4.up.railway.app/api/guidances/$guidanceId?populate=Steps';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['attributes'] ?? {};
    } else {
      throw Exception('Fehler beim Laden: ${response.statusCode}');
    }
  }

  void _showGuidanceDetailsDialog(
      BuildContext context, Map<String, dynamic> guidance) {
    final description = guidance['description'] ?? 'Keine Beschreibung';
    final tools = guidance['tools'] ?? 'Keine Tools';
    final steps = guidance['Steps'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(guidance['title'] ?? 'Kein Titel'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beschreibung:\n$description'),
                const SizedBox(height: 12),
                Text('Tools:\n$tools'),
                const SizedBox(height: 12),
                if (steps.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Schritte:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...steps.map<Widget>((step) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] ?? 'Kein Titel',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(step['description'] ?? 'Keine Beschreibung'),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Lädt...'),
          ],
        ),
      ),
    );
  }

  double calculateProgress(int currentKm, int nextServiceKm) {
    if (currentKm >= nextServiceKm) return 1.0;
    return currentKm / nextServiceKm;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final selectedBike =
    user.bikes?.isNotEmpty == true ? user.bikes!.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
          child: Text(errorMessage,
              style: const TextStyle(color: Colors.red)))
          : selectedBike == null
          ? const Center(
          child: Text('No bike selected or available.',
              style: TextStyle(fontSize: 16, color: Colors.grey)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBikeHeader(selectedBike),
          _buildDescription(),
          _buildServicesTitle(),
          _buildServiceList(selectedBike, user),
        ],
      ),
    );
  }

  Widget _buildBikeHeader(dynamic selectedBike) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              selectedBike.imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, size: 100, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selectedBike.model,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text('Current KM: ${selectedBike.km}',
                  style: const TextStyle(fontSize: 18, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Text(
      'Hier findest du alle anstehenden Wartungen und Services für dein Motorrad. Halte dich an die empfohlenen Intervalle, um deine Maschine in Top-Zustand zu halten!',
      style: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );

  Widget _buildServicesTitle() => const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text(
      'Services',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
  );

  Widget _buildServiceList(dynamic selectedBike, UserModel user) {
    return Expanded(
      child: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final interval = service['interval'];
          final guidanceId = service['serviceId'];
          final currentKm = selectedBike.km;
          final nextServiceKm = service['interval'] + currentKm ?? 1;
          final progress = calculateProgress(currentKm, nextServiceKm);
          final isFadingOut = fadingOutIndexes.contains(index);

          Color? progressColor = Color.lerp(Colors.green, Colors.red, progress.clamp(0.0, 1.0));

          return AnimatedOpacity(
            opacity: isFadingOut ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  title: Text(service['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interval: $interval km',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: progressColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Progress: $currentKm/$nextServiceKm km',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.grey),
                    onPressed: () {
                      _showConfirmationDialog(
                        serviceId: service['serviceId'],
                        fin: selectedBike.fin,
                        email: user.email ?? '',
                        km: selectedBike.km,
                        index: index,
                        bikeId: selectedBike.id,
                      );
                    },
                  ),
                  onTap: () async {
                    if (guidanceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kein Service verfügbar!')),
                      );
                      return;
                    }

                    _showLoadingDialog(context);

                    try {
                      final guidance = await fetchGuidance(guidanceId);
                      Navigator.pop(context);
                      _showGuidanceDetailsDialog(context, guidance);
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Laden: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
