import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/user_model.dart';

class BikeServicePage extends StatefulWidget {
  const BikeServicePage({super.key});

  @override
  State<BikeServicePage> createState() => _BikeServicePageState();
}

class _BikeServicePageState extends State<BikeServicePage> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> services = [];

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

    try {
      final response = await http.get(
        Uri.parse(
          '${Config.baseUrl}maintenance/getServicesByBike?bikeId=${selectedBike.id}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          services = data['services'];
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final selectedBike = user.bikes?.isNotEmpty == true ? user.bikes!.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Services'),
        elevation: 2,
        backgroundColor: Colors.grey[900],
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
          : selectedBike == null
          ? const Center(
        child: Text(
          'No bike selected or available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          // Bike Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Bike Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    selectedBike.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 80),
                  ),
                ),
                const SizedBox(width: 16),
                // Bike Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedBike.model,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedBike.company,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'KM: ${selectedBike.km}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Services List
          Expanded(
            child: services.isNotEmpty
                ? ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade700,
                          child: const Icon(
                            Icons.build,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          service['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Interval: ${service['interval']} km',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                'No services found for this bike.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
