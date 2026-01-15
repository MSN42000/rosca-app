import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ===================== LOGIN =====================
  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= RESET PASSWORD =================
  void showResetPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réinitialiser le mot de passe', style: TextStyles.titleM),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
              style: TextStyles.bodyM,
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          CustomTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context),
            color: AppColors.textSecondary,
          ),
          CustomButton(
            text: 'Envoyer',
            onPressed: () async {
              if (resetEmailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez entrer votre email')),
                );
                return;
              }

              try {
                await _authService
                    .resetPassword(resetEmailController.text.trim());
                Navigator.pop(context); // <-- Fermeture du dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email de réinitialisation envoyé !'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Connexion',
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        leading: SizedBox(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image(
                    image: const AssetImage('assets/logo.png'),
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('Bienvenue !',
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.primaryDark),
                      textAlign: TextAlign.center),
                  SizedBox(height: AppSpacing.sm),
                  Text('Connectez-vous à votre compte',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'exemple@email.com',
                      prefixIcon: Icon(Icons.email, color: AppColors.primary),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Veuillez entrer votre email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) return 'Email invalide';
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer votre mot de passe';
                      if (value.length < 6)
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      text: 'Mot de passe oublié ?',
                      onPressed: _isLoading ? () {} : showResetPasswordDialog,
                      color: AppColors.primary,
                      underline: true,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  CustomButton(
                    text: 'Se connecter',
                    onPressed: _isLoading ? () {} : login,
                    isLoading: _isLoading,
                    padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.md, horizontal: AppSpacing.xxl),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text('OU',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pas encore de compte ?',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textPrimary)),
                      CustomTextButton(
                        text: 'Inscrivez-vous',
                        onPressed: _isLoading
                            ? () {}
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RegisterScreen()),
                                );
                              },
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
