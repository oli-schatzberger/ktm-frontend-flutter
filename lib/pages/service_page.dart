import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ktmserviceapp/pages/guidanceDetail_page.dart';
import 'dart:convert';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<dynamic> _guidances = [];
  List<dynamic> _filteredGuidances = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGuidances();

    // Listen to changes in the search field
    _searchController.addListener(() {
      filterGuidances(_searchController.text);
    });
  }

  Future<void> fetchGuidances() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://strapi-production-23a4.up.railway.app/api/guidances?populate[headerImg]=*&populate[video]=*&populate[Steps][populate]=media',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _guidances = data['data'] ?? [];
          _filteredGuidances = _guidances;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch guidances: ${response.statusCode}';
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

  void filterGuidances(String query) {
    setState(() {
      _filteredGuidances = _guidances.where((guidance) {
        final title = guidance['attributes']['title']?.toLowerCase() ?? '';
        final description =
            guidance['attributes']['description']?.toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Booklet'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a guidance...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
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
          : _filteredGuidances.isEmpty
          ? const Center(
        child: Text(
          'No guidances found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchGuidances,
        child: ListView.builder(
          itemCount: _filteredGuidances.length,
          itemBuilder: (context, index) {
            final guidance = _filteredGuidances[index];
            final attributes = guidance['attributes'];
            final title = attributes['title'] ?? 'No Title';
            final description =
                attributes['description'] ?? '';
            final headerImg = attributes['headerImg']?['data']
            ?['attributes']['url'] ??
                null;

            final backgroundImage = headerImg != null
                ? 'https://strapi-production-23a4.up.railway.app$headerImg'
                : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GuidanceDetailPage(guidance: guidance),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    if (backgroundImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          backgroundImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      height: 200,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
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
    );
  }
}
