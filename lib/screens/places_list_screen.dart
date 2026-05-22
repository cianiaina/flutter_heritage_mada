import 'package:flutter/material.dart';
import 'package:flutter_heritage_mada/services/api_service.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';
import 'place_details_bottom_sheet.dart';

class PlaceListScreen extends StatefulWidget {
  const PlaceListScreen({super.key});

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Place>> _placesFuture;

  static const Color terracotta = Color(0xFFA63D40);
  static const Color creamBackground = Color(0xF8F5F2);
  static const Color darkText = Color(0xFF2B2B2B);
  static const Color accentGreen = Color(0xFF5E8C61);

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() {
    setState(() {
      _placesFuture = _apiService.fetchPlaces();
    });
  }

  void _openPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: PlaceDetailsBottomSheet(place: place),
      ),
    );
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
        iconTheme: const IconThemeData(color: darkText),
        title: const Text(
          'PATRIMOINE MADA',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 2.0,
          ),
        ),
        shape: Border(bottom: BorderSide(color: darkText.withOpacity(0.05), width: 1)),
      ),
      body: FutureBuilder<List<Place>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: terracotta, strokeWidth: 2.5));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Aucun site culturel trouvé.',
                style: TextStyle(color: darkText.withOpacity(0.5), fontWeight: FontWeight.w500),
              ),
            );
          }

          final places = snapshot.data!;

          return RefreshIndicator(
            color: terracotta,
            backgroundColor: creamBackground,
            onRefresh: () async => _loadPlaces(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: InkWell(
                    onTap: () => _openPlaceDetails(place),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkText.withOpacity(0.04), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: terracotta.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: terracotta, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.nameFr,
                                    style: const TextStyle(color: darkText, fontWeight: FontWeight.w700, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    place.nameMg,
                                    style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 13, fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentGreen.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      place.category.toUpperCase(),
                                      style: const TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: darkText.withOpacity(0.2), size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}