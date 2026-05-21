import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Si c'est une requête OPTIONS (pré-vérification du navigateur), on répond directement OK
    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 204,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        },
      );
    }

    // Sinon, on laisse la requête s'exécuter normalement
    final response = await handler(context);

    // Et on ajoute les en-têtes CORS à la réponse
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      },
    );
  };
}