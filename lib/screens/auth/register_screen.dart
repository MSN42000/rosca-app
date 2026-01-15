import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte créé avec succès ! Bienvenue ${nameController.text.trim()}'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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
      appBar: CustomAppBar(title: 'Créer un compte', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou image
                Image(
                  image: const AssetImage('assets/logo.png'),
                  height: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: AppSpacing.lg),

                // Titre et sous-titre
                Text(
                  'Inscription',
                  style: TextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Créez votre compte pour commencer',
                  style: TextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),

                // Champs du formulaire
                _buildTextField(
                  controller: nameController,
                  label: 'Nom complet',
                  hint: 'Ex: Jean Dupont',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre nom';
                    if (value.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'exemple@email.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Email invalide';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: phoneController,
                  label: 'Téléphone (optionnel)',
                  hint: '+212 6 00 00 00 00',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && value.trim().length < 10)
                      return 'Numéro de téléphone invalide';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: passwordController,
                  label: 'Mot de passe',
                  hint: 'Minimum 6 caractères',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                    if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Retapez votre mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg),

                // Bouton S'inscrire
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: register,
                  isLoading: _isLoading,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxl),
                  type: ButtonType.secondary,
                ),
                SizedBox(height: AppSpacing.md),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Déjà un compte ? ', style: TextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                    CustomTextButton(
                      text: 'Connectez-vous',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}