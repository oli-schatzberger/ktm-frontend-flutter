import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../models/user_model.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class AddBikePage extends StatefulWidget {
  const AddBikePage({super.key});

  @override
  State<AddBikePage> createState() => _AddBikePageState();
}

class _AddBikePageState extends State<AddBikePage> {
  final String strapiUrl =
      'https://strapi-production-23a4.up.railway.app/api/bikes?populate=%2A';
  final String quarkusUrl = '${Config.baseUrl}maintenance/addBike';
  List<Map<String, dynamic>> bikes = [];
  String? selectedBikeId;

  @override
  void initState() {
    super.initState();
    fetchBikesFromStrapi();
  }

  Future<void> fetchBikesFromStrapi() async {
    try {
      final response = await http.get(Uri.parse(strapiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bikes = List<Map<String, dynamic>>.from(data['data'].map((bike) {
            final bikeId = bike['id'];
            final bikeModel = bike['attributes']['model'];
            final company = bike['attributes']['company'];
            final imageUrl = bike['attributes']['image']['data']['attributes']
            ['formats']['medium']['url'];
            if (bikeId != null && bikeModel != null && imageUrl != null) {
              return {
                'id': bikeId,
                'model': bikeModel,
                'company': company,
                'image': imageUrl,
              };
            }
            return null; // Skip invalid entries
          }).where((bike) => bike != null)); // Remove null entries
        });
      } else {
        _showMessage('Failed to load bikes: ${response.body}', Colors.red);
      }
    } catch (e) {
      _showMessage('Error loading bikes: $e', Colors.red);
    }
  }

  Future<void> addBike(String bikeId, String km, String fin, String userEmail) async {
    final selectedBike =
    bikes.firstWhere((bike) => bike['id'].toString() == bikeId);

    try {
      final response = await http.post(
        Uri.parse(quarkusUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fin': fin,
          'email': userEmail,
          'bikeId': int.parse(bikeId),
          'km': int.parse(km),
          'imgUrl': 'https://strapi-production-23a4.up.railway.app${selectedBike['image']}',
        }),
      );

      if (response.statusCode == 200) {
        Provider.of<UserModel>(context, listen: false).addBike(
          Bike(
            id: int.parse(bikeId),
            model: selectedBike['model'],
            company: selectedBike['company'],
            km: int.parse(km),
            imageUrl: 'https://strapi-production-23a4.up.railway.app${selectedBike['image']}',
            fin: fin,
          ),
        );

        _showMessage('Bike added successfully!', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showMessage('Failed to add bike: ${response.body}', Colors.red);
        print(response.body);
      }
    } catch (e) {
      _showMessage('An error occurred: $e', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _showKilometerDialog(BuildContext context) async {
    final user = Provider.of<UserModel>(context, listen: false);
    String? km;
    String? fin;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FIN Input Field
              TextField(
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  fin = value;
                },
                decoration: const InputDecoration(
                  labelText: 'FIN',
                  border: OutlineInputBorder(),
                  hintText: 'Enter bike FIN',
                ),
              ),
              const SizedBox(height: 10),
              // Kilometer Input Field
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  km = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Kilometers',
                  border: OutlineInputBorder(),
                  hintText: 'Enter bike kilometers',
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
                if (fin != null && fin!.isNotEmpty && km != null && km!.isNotEmpty) {
                  Navigator.of(context).pop();
                  addBike(selectedBikeId!, km!, fin!, user.email!);
                } else {
                  _showMessage('Please enter both FIN and kilometers!', Colors.red);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bike'),
        actions: [
          if (selectedBikeId != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () => _showKilometerDialog(context),
            ),
        ],
      ),
      body: bikes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bikes.length,
        itemBuilder: (context, index) {
          final bike = bikes[index];
          final isSelected = bike['id'].toString() == selectedBikeId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedBikeId = bike['id'].toString();
              });
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://strapi-production-23a4.up.railway.app${bike['image']}',
                  ),
                ),
                title: Text(
                  bike['model'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(bike['company']),
              ),
            ),
          );
        },
      ),
    );
  }
}
