class Place {
  final int id;
  final String nameFr;
  final String nameMg;
  final String description;
  final String descriptionMg; // Nouvelle colonne
  final String category;      // Nouvelle colonne
  final String imageUrl;      // Nouvelle colonne
  final double longitude;
  final double latitude;

  Place({
    required this.id,
    required this.nameFr,
    required this.nameMg,
    required this.description,
    required this.descriptionMg,
    required this.category,
    required this.imageUrl,
    required this.longitude,
    required this.latitude,
  });

  // Cette fonction magique transforme le JSON PostGIS du backend en objet Flutter
  factory Place.fromJson(Map<String, dynamic> json) {
    // On conserve ton extraction des coordonnées depuis le format "POINT(47.5323 -18.9221)"
    final coordsString = json['coordinates'] as String;
    final cleanCoords = coordsString
        .replaceAll('POINT(', '')
        .replaceAll(')', '')
        .split(' ');

    return Place(
      id: json['id'] as int,
      nameFr: json['name']['fr'] as String? ?? '',
      nameMg: json['name']['mg'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionMg: json['description_mg'] as String? ?? '', // Parsing du texte MG
      category: json['category'] as String? ?? 'Patrimoine',    // Valeur par défaut si null
      imageUrl: json['image_url'] as String? ?? '',            // Valeur par défaut si vide
      longitude: double.parse(cleanCoords[0]),
      latitude: double.parse(cleanCoords[1]),
    );
  }
}