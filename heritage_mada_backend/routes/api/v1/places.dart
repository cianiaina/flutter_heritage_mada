import 'package:dart_frog/dart_frog.dart';
import 'package:heritage_mada_backend/src/database_client.dart';
import 'dart:convert'; // Indispensable pour gérer le format JSONB

Future<Response> onRequest(RequestContext context) async {
  try {
    final db = await DatabaseClient.connection;

    // 1. On interroge la table 'places' que nous venons de créer et remplir
    final results = await db.execute(
      'SELECT id, name, description, description_mg, category, image_url, coordinates FROM public.places',
    );

    final places = results.map((row) {
      // row[x] récupère la valeur de la colonne selon l'ordre du SELECT
      final id = row[0];
      
      // Sécurité si 'name' arrive sous forme de String JSON ou directement de Map
      final nameData = row[1];
      final nameJson = nameData is String ? jsonDecode(nameData) : nameData;

      final descriptionFr = row[2] ?? '';
      final descriptionMg = row[3] ?? '';
      final category = row[4] ?? 'Patrimoine';
      final imageUrl = row[5] ?? '';
      final coordinates = row[6] ?? ''; // C'est notre chaîne "POINT(lon lat)"

      return {
        'id': id,
        'name': nameJson, // Renvoie le format attendu {"fr": "...", "mg": "..."}
        'description': descriptionFr,
        'description_mg': descriptionMg, // Ajouté pour Flutter
        'category': category,             // Ajouté pour Flutter
        'image_url': imageUrl,           // Ajouté pour Flutter
        'coordinates': coordinates,       // Renvoie directement "POINT(lon lat)"
      };
    }).toList();

    return Response.json(body: places);
  } catch (e) {
    return Response.json(
      body: {'error': 'Erreur backend : ${e.toString()}'},
      statusCode: 500,
    );
  }
}