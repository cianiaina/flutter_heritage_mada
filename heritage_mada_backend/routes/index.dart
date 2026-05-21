import 'package:dart_frog/dart_frog.dart';
import 'package:heritage_mada_backend/src/database_client.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    // Vérification de la connexion à la base de données PostgreSQL
    final db = await DatabaseClient.connection;
    
    return Response(
      body: 'Connexion à PostgreSQL réussie !',
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
    );
  } catch (e) {
    // Retourne l'erreur proprement en cas de problème de connexion
    return Response(
      body: 'Erreur de connexion : $e',
      statusCode: 500,
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
    );
  }
}