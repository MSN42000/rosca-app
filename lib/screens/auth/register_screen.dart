import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers pour les champs de formulaire
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Valide et enregistre un nouveau compte utilisateur
  void register() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier que les mots de passe correspondent
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
      );

      if (user != null) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte créé avec succès ! Bienvenue ${nameController.text.trim()}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Rediriger vers l'écran de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      // Afficher le message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Nettoyer les controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre et sous-titre
                Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Créez votre compte pour commencer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Champ Nom complet
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Ex: Jean Dupont',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.trim().length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Champ Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemple@email.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    // Validation basique de l'email
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Champ Téléphone (optionnel)
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    hintText: '+212 6 00 00 00 00',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // Validation optionnelle
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10) {
                        return 'Numéro de téléphone invalide';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Champ Mot de passe
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Minimum 6 caractères',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Champ Confirmer mot de passe
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Retapez votre mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Bouton S'inscrire
                ElevatedButton(
                  onPressed: _isLoading ? null : register,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),

                // Lien vers la page de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Connectez-vous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}