import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ktmserviceapp/pages/service_page.dart';
import 'package:ktmserviceapp/pages/handbook_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../components/my_drawer.dart';
import '../models/user_model.dart';
import 'addbike_page.dart';
import 'bikeservice_page.dart';
import 'bikedetail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllBikeDetails();
  }

  Future<void> _fetchAllBikeDetails() async {
    final user = Provider.of<UserModel>(context, listen: false);

    if (user.bikes == null || user.bikes!.isEmpty) return;

    for (final bike in user.bikes!) {
      await fetchBikeDetailsFromStrapi(bike.id);
    }
  }

  Future<void> fetchBikeDetailsFromStrapi(int bikeId) async {
    const strapiBaseUrl = "https://strapi-production-23a4.up.railway.app/api";

    try {
      final response = await http.get(Uri.parse("$strapiBaseUrl/bikes/$bikeId?populate=*"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newImageUrl = data['data']['attributes']['image']?['data']?['attributes']?['url'] ?? '';
        final fullImageUrl = newImageUrl.startsWith('http')
            ? newImageUrl
            : 'https://strapi-production-23a4.up.railway.app$newImageUrl';

        final user = Provider.of<UserModel>(context, listen: false);
        final bikeIndex = user.bikes?.indexWhere((bike) => bike.id == bikeId);

        if (bikeIndex != null && bikeIndex >= 0) {
          final bike = user.bikes![bikeIndex];

          user.bikes![bikeIndex] = Bike(
            id: bike.id,
            model: bike.model,
            company: bike.company,
            km: bike.km,
            imageUrl: fullImageUrl,
            fin: bike.fin,
          );

          user.notifyListeners();
        }
      } else {
        throw Exception("Failed to fetch bike details from Strapi");
      }
    } catch (e) {
      _showMessage("Error fetching bike details: $e", Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    final List<Widget> _pages = [
      user.bikes == null || user.bikes!.isEmpty
          ? Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddBikePage(),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepOrange,
                    width: 3.0,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: const Icon(
                  Icons.add,
                  size: 50,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Motorrad hinzufügen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )
          : GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BikeDetailPage(),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    user.bikes![0].imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.bikes![0].model,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Company: ${user.bikes![0].company}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KM: ${user.bikes![0].km}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const ServicePage(),
      const HandbookPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const MyDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          color: Colors.black,
          activeColor: Colors.deepOrange,
          tabBackgroundColor: Colors.black,
          gap: 6,
          padding: const EdgeInsets.all(16),
          selectedIndex: _selectedIndex,
          onTabChange: (index) async {
            setState(() {
              _selectedIndex = index;
            });

            // 🔥 When the Garage tab is tapped or user navigates back
            if (index == 0) {
              await _fetchAllBikeDetails();
            }
          },
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Garage',
            ),
            GButton(
              icon: Icons.build,
              text: 'Service',
            ),
            GButton(
              icon: Icons.menu_book,
              text: 'Handbuch',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
