import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? email;
  String? firstname;
  String? lastname;
  List<Bike>? bikes;

  void setUser(Map<String, dynamic> data) {
    final userData = data['user'];
    final bikesData = data['bikes'];

    if (userData != null) {
      email = userData['email'];
      firstname = userData['firstname'];
      lastname = userData['lastname'];
    }

    if (bikesData != null && bikesData is List) {
      bikes = bikesData.map((bike) => Bike.fromJson(bike)).toList();
    }

    notifyListeners();
  }

  void addBike(Bike bike) {
    bikes ??= [];
    bikes!.add(bike);
    notifyListeners();
  }

  void clearUser() {
    email = null;
    firstname = null;
    lastname = null;
    bikes = null;
    notifyListeners();
  }

  /// ✅ NEW: Update the kilometers of a bike by its ID
  void updateBikeKm(int bikeId, int newKm) {
    if (bikes == null || bikes!.isEmpty) return;

    final index = bikes!.indexWhere((bike) => bike.id == bikeId);
    if (index != -1) {
      final oldBike = bikes![index];

      bikes![index] = Bike(
        id: oldBike.id,
        model: oldBike.model,
        company: oldBike.company,
        km: newKm,
        imageUrl: oldBike.imageUrl,
        fin: oldBike.fin,
      );

      notifyListeners();
      debugPrint('✅ Updated bike ID $bikeId with new KM: $newKm');
    } else {
      debugPrint('❌ Bike with ID $bikeId not found.');
    }
  }
}

class Bike {
  final int id;
  final String model;
  final String company;
  final int km;
  final String imageUrl;
  final String fin; // ✅ FIN Field

  Bike({
    required this.id,
    required this.model,
    required this.company,
    required this.km,
    required this.imageUrl,
    required this.fin,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    final bikeData = json['bike'];
    return Bike(
      id: bikeData['id'],
      model: bikeData['model'],
      company: bikeData['brand'],
      km: json['km'],
      imageUrl: bikeData['image'] ?? '',
      fin: json['fin'] ?? '',
    );
  }

  // Neues Parsing direkt aus Strapi "populate=*"-Struktur
  factory Bike.fromStrapiJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final imageUrl = attributes['image']?['data']?['attributes']?['url'] ?? '';

    return Bike(
      id: json['id'],
      model: attributes['model'] ?? '',
      company: attributes['brand'] ?? '',
      km: attributes['km'] ?? 0,
      imageUrl: imageUrl.startsWith('http') ? imageUrl : 'https://strapi-production-23a4.up.railway.app$imageUrl',
      fin: attributes['fin'] ?? '',
    );
  }
}
