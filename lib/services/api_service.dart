import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api/v1';

  
  Future<List<Place>> fetchPlaces() async {
    final prefs = await SharedPreferences.getInstance();

    //  Vérifier si l'appareil a une connexion Internet active
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      try {
        print("Connexion détectée : Récupération des données depuis Dart Frog...");
        final response = await http.get(Uri.parse('$baseUrl/places'));

        if (response.statusCode == 200) {
          // Le serveur a répondu OK, on sauvegarde le JSON brut en local pour plus tard
          await prefs.setString('cached_places', response.body);

          
          final List<dynamic> body = jsonDecode(response.body);
          return body.map((dynamic item) => Place.fromJson(item)).toList();
        }
      } catch (e) {
        print("Serveur inaccessible (Dart Frog éteint ?). Bascule sur le cache local...");
      }
    }

    // 2. Mode Hors-ligne ou serveur planté -> On lit le cache local de SharedPreferences
    print("Mode hors-ligne : Lecture des données stockées dans le téléphone.");
    final String? cachedString = prefs.getString('cached_places');

    if (cachedString != null) {
      final List<dynamic> body = jsonDecode(cachedString);
      return body.map((dynamic item) => Place.fromJson(item)).toList();
    } else {
      // Si l'application n'a jamais été ouverte avec internet au moins une fois
      print("Aucun cache disponible sur l'appareil.");
      return [];
    }
  }

  // --- POST : Ajouter un nouveau site ---
  Future<bool> addPlace({
    required String nameFr,
    required String nameMg,
    required String description,
    required double longitude,
    required double latitude,
  }) async {
    try {
      // Pour le POST, on vérifie aussi s'il y a du réseau
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("Impossible d'ajouter un lieu : vous êtes hors-ligne !");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/places'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name_fr': nameFr,
          'name_mg': nameMg,
          'description_fr': description,
          'longitude': longitude,
          'latitude': latitude,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la requête POST addPlace : $e');
      return false;
    }
  }
}