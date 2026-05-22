import 'package:flutter/material.dart';
import 'package:flutter_heritage_mada/models/place_model.dart';

class PlaceDetailsBottomSheet extends StatelessWidget {
  final Place place;

  const PlaceDetailsBottomSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    const Color terracotta = Color(0xFFA63D40);
    const Color darkText = Color(0xFF2B2B2B);
    const Color accentGreen = Color(0xFF5E8C61);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xF8F5F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    place.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        place.category.toUpperCase(),
                        style: const TextStyle(
                          color: accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      place.nameFr,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.nameMg,
                      style: TextStyle(fontSize: 16, color: darkText.withOpacity(0.6), fontStyle: FontStyle.italic),
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.black12),
                    _buildHistoryTile('Historique (En français)', place.description, Icons.history, terracotta, darkText),
                    const SizedBox(height: 12),
                    _buildHistoryTile(
                      "Tantara (Amin'ny teny malagasy)",
                      place.descriptionMg.isNotEmpty ? place.descriptionMg : 'Tsy misy dika teny malagasy.',
                      Icons.g_translate,
                      terracotta,
                      darkText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String content, IconData icon, Color iconColor, Color textColor) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12, width: 1),
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: iconColor.withOpacity(0.03),
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
          ),
          iconColor: iconColor,
          collapsedIconColor: iconColor,
          textColor: textColor,
          collapsedTextColor: textColor,
          childrenPadding: const EdgeInsets.all(16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              content,
              style: TextStyle(fontSize: 15, height: 1.5, color: textColor.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}