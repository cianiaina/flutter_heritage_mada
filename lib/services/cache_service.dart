import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CacheService {
  final Dio _dio = Dio();
  // L'adresse de ton serveur Dart Frog (port 8080 par défaut)
  final String _apiUrl = 'http://localhost:8080/api/v1/places';

  Future<List<dynamic>> getHeritageData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Vérifier si l'appareil a une connexion Internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      try {
        print("Connexion détectée : Récupération des données depuis Dart Frog...");
        final response = await _dio.get(_apiUrl);

        if (response.statusCode == 200) {
          final data = response.data;
          // On convertit en chaîne JSON pour le stocker en cache local
          await prefs.setString('cached_monuments', json.encode(data));
          return data is List ? data : [data];
        }
      } catch (e) {
        print("Erreur lors de l'appel au serveur (Dart Frog éteint ?). Tentative via le cache local...");
      }
    }

    // 2. Mode Hors-ligne ou serveur inaccessible -> Chargement du cache local
    print("Mode hors-ligne activé : Récupération des récits sauvegardés...");
    final String? cachedString = prefs.getString('cached_monuments');

    if (cachedString != null) {
      return json.decode(cachedString) as List<dynamic>;
    } else {
      // Si l'utilisateur n'a jamais ouvert l'application avec Internet
      print("Aucune donnée en cache disponible.");
      return [];
    }
  }
}