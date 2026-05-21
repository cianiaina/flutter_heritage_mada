import 'package:flutter/material.dart';
import  'package:flutter_heritage_mada/services/api_service.dart'; // Ajuste le chemin selon ton projet
import 'package:flutter_heritage_mada/models/place_model.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Place>> _placesFuture;

 @override
  void initState() {
    super.initState(); 
    
    _placesFuture = _apiService.fetchPlaces();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrimoine de Madagascar'),
        backgroundColor: Colors.brown, // Un joli ton chaleureux pour le patrimoine
      ),
      body: FutureBuilder<List<Place>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun site trouvé.'));
          }

          final places = snapshot.data!;

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.brown),
                  title: Text('${place.nameFr} (${place.nameMg})'),
                  subtitle: Text(place.description),
                  trailing: Text('${place.latitude.toStringAsFixed(2)}, ${place.longitude.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}