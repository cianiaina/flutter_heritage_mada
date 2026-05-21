import 'package:flutter/material.dart';
import 'screens/places_map_screen.dart'; 

void main() {
  runApp(const HeritageMadaApp());
}

class HeritageMadaApp extends StatelessWidget {
  const HeritageMadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeritageMada',
      debugShowCheckedModeBanner: false,
      // On utilise temporairement un thème de base pour tuer le rouge immédiatement
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const PlacesMapScreen(), 
    );
  }
}