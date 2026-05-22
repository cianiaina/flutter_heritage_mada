import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_heritage_mada/services/api_service.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';
import 'package:flutter_heritage_mada/screens/add_place_screen.dart';
import './place_details_bottom_sheet.dart';
import './place_search_delegate.dart';

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
  String _currentRoute = 'carte';

  bool _isSelectionMode = false;
  LatLng? _temporaryPoint;

  static const Color terracotta = Color(0xFFA63D40);
  static const Color creamBackground = Color(0xF8F5F2);
  static const Color darkText = Color(0xFF2B2B2B);
  static const Color greenAccent = Color(0xFF5E8C61);

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

  void _openPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (_) => PlaceDetailsBottomSheet(place: place),
    );
  }

  void _handleMapTap(LatLng point) async {
    if (!_isSelectionMode) return;

    setState(() => _temporaryPoint = point);

    _mapController.move(point, _mapController.camera.zoom);
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    final refresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => AddPlaceScreen(latitude: point.latitude, longitude: point.longitude),
    );

    setState(() {
      _isSelectionMode = false;
      _temporaryPoint = null;
    });

    if (refresh == true) _loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: creamBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText, size: 22),
        title: const Text('HERITAGE MADA', style: TextStyle(color: darkText, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2.0)),
        shape: Border(bottom: BorderSide(color: darkText.withOpacity(0.05))),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => showSearch(
              context: context,
              delegate: PlaceSearchDelegate(
                places: _allPlaces,
                onPlaceSelected: (place) {
                  _mapController.move(LatLng(place.latitude, place.longitude), 13.0);
                  _openPlaceDetails(place);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: creamBackground,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text('HERITAGE MADA', style: TextStyle(color: terracotta, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text('Patrimoine de Madagascar', style: TextStyle(color: darkText.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 32),
                _buildDrawerItem(Icons.map_outlined, 'Carte des sites', 'carte', () => Navigator.pop(context)),
                const SizedBox(height: 8),
                _buildDrawerItem(Icons.sync_rounded, 'Synchroniser', 'sync', () {
                  Navigator.pop(context);
                  _loadPlaces();
                }),
                const Spacer(),
                Divider(color: darkText.withOpacity(0.08)),
                Text('Version 1.0.0', style: TextStyle(color: darkText.withOpacity(0.3), fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Place>>(
            future: _placesFuture,
            builder: (context, snapshot) {
              final places = snapshot.data ?? [];

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(-18.9236, 47.5323),
                  initialZoom: 6.5,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  onTap: (_, point) => _handleMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.heritagemada.app',
                  ),
                  MarkerLayer(
                    markers: [
                      ...places.map((place) => Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _isSelectionMode ? null : _openPlaceDetails(place),
                          child: _buildMarkerWidget(terracotta, Icons.account_balance_rounded),
                        ),
                      )),
                      if (_temporaryPoint != null)
                        Marker(
                          point: _temporaryPoint!,
                          width: 52,
                          height: 52,
                          child: _buildMarkerWidget(greenAccent, Icons.add_location_alt_rounded),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          if (_isSelectionMode)
            Positioned(
              top: 20,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: darkText,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded, color: creamBackground, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Choisissez l’emplacement du patrimoine',
                      style: TextStyle(color: creamBackground, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSelectionMode
            ? FloatingActionButton.extended(
                key: const ValueKey('cancelBtn'),
                elevation: 2,
                backgroundColor: Colors.white,
                foregroundColor: terracotta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: terracotta.withOpacity(0.3))),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Annuler la sélection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                onPressed: () => setState(() => _isSelectionMode = false),
              )
            : FloatingActionButton.extended(
                key: const ValueKey('addBtn'),
                elevation: 4,
                backgroundColor: terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('Ajouter un patrimoine', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.2)),
                onPressed: () => setState(() {
                  _isSelectionMode = true;
                  _temporaryPoint = null;
                }),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMarkerWidget(Color baseColor, IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: baseColor.withOpacity(0.2), shape: BoxShape.circle)),
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
          child: Icon(icon, color: Colors.white, size: 11),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, String routeId, VoidCallback onTap) {
    final bool isActive = _currentRoute == routeId;
    return ListTile(
      selected: isActive,
      selectedTileColor: terracotta.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: isActive ? terracotta : darkText.withOpacity(0.6), size: 20),
      title: Text(label, style: TextStyle(color: isActive ? terracotta : darkText, fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
      onTap: () {
        setState(() => _currentRoute = routeId);
        onTap();
      },
    );
  }
}