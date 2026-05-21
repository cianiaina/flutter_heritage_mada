import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _nameFrController = TextEditingController();
  final _nameMgController = TextEditingController();
  final _descController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  bool _isLoading = false;

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _apiService.addPlace(
      nameFr: _nameFrController.text, // Le "2" a été supprimé ici
      nameMg: _nameMgController.text,
      description: _descController.text,
      latitude: double.parse(_latController.text),
      longitude: double.parse(_lngController.text),
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Site historique ajouté avec succès !')),
      );
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'envoi au serveur.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Patrimoine')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameFrController,
                      decoration: const InputDecoration(labelText: 'Nom (Français)'),
                      validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                    ),
                    TextFormField(
                      controller: _nameMgController,
                      decoration: const InputDecoration(labelText: 'Nom (Malagasy)'),
                      validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude (ex: -18.92)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v!) == null ? 'Nombre valide requis' : null,
                    ),
                    TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude (ex: 47.53)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v!) == null ? 'Nombre valide requis' : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                      onPressed: _submitData,
                      child: const Text('Enregistrer le site'),
                    ),
                  ],
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
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}