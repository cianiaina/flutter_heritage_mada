import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_heritage_mada/services/api_service.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';
import 'package:flutter_heritage_mada/core/theme/app_theme.dart';
import 'package:flutter_heritage_mada/screens/add_place_screen.dart';

class PlacesMapScreen extends StatefulWidget {
  const PlacesMapScreen({super.key});
  @override
  State<PlacesMapScreen> createState() => _PlacesMapScreenState();
}

class _PlacesMapScreenState extends State<PlacesMapScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  late Future<List<Place>> _placesFuture;
  List<Place> _allPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() {
    setState(() {
      _placesFuture = _apiService.fetchPlaces().then((places) => _allPlaces = places);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HERITAGE MADA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: PlaceSearchDelegate(
                places: _allPlaces,
                onPlaceSelected: (place) {
                  _mapController.move(LatLng(place.latitude, place.longitude), 12.0);
                  _showPlaceDetails(place);
                },
              ),
            ),
          ),
        ],
      ),
      
      // ─── NOUVEAU : LE MENU LATÉRAL COULISSANT (DRAWER) ───
      drawer: Drawer(
        child: Container(
          color: Colors.grey[900], // Reste sur ton design sombre
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.greenForest,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'HERITAGE MADA',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Patrimoine Culturel Malagasy',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.white),
                title: const Text('Carte des sites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context); // Ferme simplement le menu
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.white),
                title: const Text('Synchroniser les données', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _loadPlaces(); // Relance la recherche serveur/cache
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('À propos', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Tu pourras ajouter une navigation vers une page d'infos ici plus tard
                },
              ),
            ],
          ),
        ),
      ),

      body: FutureBuilder<List<Place>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun point a afficher.'));
          }

          final markers = snapshot.data!.map((place) => Marker(
            point: LatLng(place.latitude, place.longitude),
            width: 40, height: 40, alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => _showPlaceDetails(place),
              child: const Icon(Icons.location_on, color: AppTheme.zebuRed, size: 40),
            ),
          )).toList();

          return FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(-18.9236, 47.5323), initialZoom: 6.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.heritagemada.app',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.greenForest,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_location_alt),
        onPressed: () async {
          final refresh = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaceScreen()));
          if (refresh == true) _loadPlaces();
        },
      ),
    );
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    place.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.greenForest.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(place.category, style: const TextStyle(color: AppTheme.greenForest, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Text(place.nameFr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(place.nameMg, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                    const Divider(height: 20, thickness: 1),
                    
                    _buildHistoryTile('Historique (En francais)', place.description, Icons.history),
                    const SizedBox(height: 10),
                    _buildHistoryTile("Tantara (Amin'ny teny malagasy)", place.descriptionMg.isNotEmpty ? place.descriptionMg : 'Tsy misy dika teny malagasy.', Icons.g_translate),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String content, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.greenForest),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        childrenPadding: const EdgeInsets.all(16),
        expandedAlignment: Alignment.topLeft,
        children: [Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87))],
      ),
    );
  }
}

class PlaceSearchDelegate extends SearchDelegate {
  final List<Place> places;
  final Function(Place) onPlaceSelected;

  PlaceSearchDelegate({required this.places, required this.onPlaceSelected});

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    final results = places.where((p) {
      final s = query.toLowerCase();
      return p.nameFr.toLowerCase().contains(s) || p.nameMg.toLowerCase().contains(s) || p.category.toLowerCase().contains(s);
    }).toList();

    if (results.isEmpty) return const Center(child: Text('Aucun site culturel trouve.'));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final p = results[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: AppTheme.greenForest),
          title: Text(p.nameFr, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${p.nameMg} • ${p.category}', style: const TextStyle(fontStyle: FontStyle.italic)),
          onTap: () {
            close(context, null);
            onPlaceSelected(p);
          },
        );
      },
    );
  }
}