import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTextStyles {
  // ============================================
  // 1. EN-TÊTES PRINCIPALES (Headers)
  // ============================================

  /// Très gros titre - Pour les écrans d'accueil
  static TextStyle displayLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Gros titre - Pour les titres de section
  static TextStyle displayMedium = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Titre moyen - Pour les noms de groupes
  static TextStyle displaySmall = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Titre de section - Pour "Mes Groupes", "Historique"
  static TextStyle headlineMedium = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ============================================
  // 2. TITRES
  // ============================================

  /// Titre de carte - Pour les noms dans les cartes
  static TextStyle titleLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Titre de liste - Pour les items de liste
  static TextStyle titleMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Petit titre - Pour les sous-titres
  static TextStyle titleSmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ============================================
  // 3. TEXTE CORPS (Body Text)
  // ============================================

  /// Texte corps grand - Pour descriptions importantes
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Texte corps moyen - PAR DÉFAUT pour la plupart du texte
  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Texte corps petit - Pour les détails secondaires
  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ============================================
  // 4. LABELS & BOUTONS
  // ============================================

  /// Label grand - Pour les labels de champs
  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Label moyen - Pour les badges, tags
  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Label petit - Pour les infos très petites
  static TextStyle labelSmall = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textDisabled,
  );

  /// Texte de bouton grand
  static TextStyle buttonLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Texte de bouton moyen (utilisé dans CustomButton)
  static TextStyle buttonMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ============================================
  // 5. STYLES SPÉCIAUX
  // ============================================

  /// Légende - Pour les crédits, copyright
  static TextStyle caption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Overline - Très petit texte décoratif
  static TextStyle overline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textDisabled,
  );

  /// Argent/Montants - Pour les sommes d'argent
  static TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle amountMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle amountSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ============================================
  // 6. STYLES POUR ÉTATS (Status)
  // ============================================

  /// Texte succès (vert)
  static TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  /// Texte avertissement (orange)
  static TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
  );

  /// Texte erreur (rouge)
  static TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  /// Texte info (bleu)
  static TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
  );
}

// ============================================
// SHORTCUTS UTILES (Faciles à retenir)
// ============================================

class TextStyles {
  /// h1, h2, h3, h4 - Pour les titres
  static TextStyle get h1 => AppTextStyles.displayLarge;
  static TextStyle get h2 => AppTextStyles.displayMedium;
  static TextStyle get h3 => AppTextStyles.displaySmall;
  static TextStyle get h4 => AppTextStyles.headlineMedium;

  /// titleL, titleM, titleS - Pour les titres
  static TextStyle get titleL => AppTextStyles.titleLarge;
  static TextStyle get titleM => AppTextStyles.titleMedium;
  static TextStyle get titleS => AppTextStyles.titleSmall;

  /// bodyL, bodyM, bodyS - Pour le texte normal
  static TextStyle get bodyL => AppTextStyles.bodyLarge;
  static TextStyle get bodyM => AppTextStyles.bodyMedium;
  static TextStyle get bodyS => AppTextStyles.bodySmall;

  /// button - Pour les boutons
  static TextStyle get button => AppTextStyles.buttonMedium;

  /// label - Pour les labels
  static TextStyle get label => AppTextStyles.labelMedium;

  /// caption - Pour les légendes
  static TextStyle get caption => AppTextStyles.caption;

  /// amountL, amountM, amountS - Pour l'argent
  static TextStyle get amountL => AppTextStyles.amountLarge;
  static TextStyle get amountM => AppTextStyles.amountMedium;
  static TextStyle get amountS => AppTextStyles.amountSmall;

  static get bodySmall => null;

  static get titleMedium => null;

  static get labelMedium => null;
}