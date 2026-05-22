import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPlaceScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AddPlaceScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _nameFrController = TextEditingController();
  late final TextEditingController _nameMgController = TextEditingController();
  late final TextEditingController _descController = TextEditingController();
  late final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;
  String? _imagePreviewUrl;

  static const Color terracotta = Color(0xFFA63D40);
  static const Color darkText = Color(0xFF2B2B2B);
  static const Color creamBackground = Color(0xF8F5F2);

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _apiService.addPlace(
      nameFr: _nameFrController.text,
      nameMg: _nameMgController.text,
      description: _descController.text,
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'enregistrement. Veuillez réessayer.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 36, height: 4, decoration: BoxDecoration(color: darkText.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'NOUVEAU PATRIMOINE',
                    style: TextStyle(color: terracotta, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordonnées enregistrées : ${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
                    style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  _buildCustomField(_nameFrController, 'Nom du site (Français)', Icons.title_rounded),
                  _buildCustomField(_nameMgController, "Anaran'ny toerana (Malagasy)", Icons.translate_rounded),
                  _buildCustomField(_descController, 'Description / Tantara', Icons.description_rounded, maxLines: 3),
                  _buildCustomField(
                    _imageController, 
                    "Lien URL de l'image d'illustration", 
                    Icons.image_outlined,
                    onChanged: (val) => setState(() => _imagePreviewUrl = val),
                  ),
                  _buildImagePreview(),

                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: terracotta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _submitData,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Publier le patrimoine', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: darkText.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, size: 18, color: darkText.withOpacity(0.4)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkText.withOpacity(0.05))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: terracotta, width: 1.2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagePreviewUrl == null || _imagePreviewUrl!.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _imagePreviewUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, color: terracotta.withOpacity(0.6), size: 16),
                const SizedBox(width: 8),
                Text('Format d’image invalide', style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameFrController.dispose();
    _nameMgController.dispose();
    _descController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}