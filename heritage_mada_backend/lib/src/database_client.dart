import 'package:postgres/postgres.dart';

class DatabaseClient {
  static Connection? _connection;

  static Future<Connection> get connection async {
    // Si la connexion existe et est ouverte, on la réutilise
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'heritage_mada',
          username: 'postgres',
          password: 'admin',
          port: 5432,
        ),
        // On simplifie ici : on retire le networkTimeout qui pose problème
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );
      return _connection!;
    } catch (e) {
      // En cas d'erreur, on s'assure que _connection est nul pour pouvoir réessayer
      _connection = null;
      rethrow;
    }
  }
}