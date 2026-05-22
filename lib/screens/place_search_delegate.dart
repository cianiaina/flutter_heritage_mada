import 'package:flutter/material.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';

class PlaceSearchDelegate extends SearchDelegate {
  final List<Place> places;
  final Function(Place) onPlaceSelected;

  static const Color terracotta = Color(0xFFA63D40);
  static const Color darkText = Color(0xFF2B2B2B);

  PlaceSearchDelegate({required this.places, required this.onPlaceSelected});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: darkText),
          onPressed: () => query = '',
        )
      ];

@override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: darkText),
        onPressed: () => close(context, null),
      );
  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    final results = places.where((p) {
      final s = query.toLowerCase();
      return p.nameFr.toLowerCase().contains(s) ||
          p.nameMg.toLowerCase().contains(s) ||
          p.category.toLowerCase().contains(s);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Aucun site culturel trouvé.',
          style: TextStyle(color: darkText.withOpacity(0.5), fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final p = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: terracotta.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_rounded, color: terracotta, size: 18),
          ),
          title: Text(
            p.nameFr,
            style: const TextStyle(color: darkText, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            '${p.nameMg} • ${p.category}',
            style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic),
          ),
          onTap: () {
            close(context, null);
            onPlaceSelected(p);
          },
        );
      },
    );
  }
}