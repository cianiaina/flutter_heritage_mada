import 'package:latlong2/latlong.dart';

class HeritagePlace {
  final String id;
  final Map<String, String> name;       
  final Map<String, String> description;
  final LatLng location;                 // Coordonnées GPS précises
  final String categoryId;
  final bool isUnesco;

  HeritagePlace({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.categoryId,
    this.isUnesco = false,
  });
}