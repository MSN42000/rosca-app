// lib/screens/groups/create_group_screen.dart

import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();

  bool _isLoading = false;

  /// Créer un nouveau groupe
  void createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final groupId = await _groupService.createGroup(
        name: nameController.text.trim(),
        monthlyAmount: double.parse(amountController.text.trim()),
        totalRounds: int.parse(roundsController.text.trim()),
        createdBy: currentUserId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Groupe "${nameController.text}" créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, groupId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    roundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un groupe'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icône
              Icon(
                Icons.group_add,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 20),

              Text(
                'Nouveau groupe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Nom du groupe
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du groupe',
                  hintText: 'Ex: Groupe Amis 2025',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Montant mensuel
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Montant mensuel (MAD)',
                  hintText: 'Ex: 1000',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Montant invalide';
                  }
                  if (double.parse(value.trim()) <= 0) {
                    return 'Le montant doit être positif';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nombre de rounds
              TextFormField(
                controller: roundsController,
                decoration: InputDecoration(
                  labelText: 'Nombre de rounds',
                  hintText: 'Ex: 12',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer le nombre de rounds';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Nombre invalide';
                  }
                  if (int.parse(value.trim()) <= 0) {
                    return 'Le nombre doit être positif';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Bouton créer
              ElevatedButton(
                onPressed: _isLoading ? null : createGroup,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Créer le groupe',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}