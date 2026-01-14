import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // 1. COULEURS PRINCIPALES (Votre marque verte)
  // ============================================
  static const Color primary = Color(0xFF2E7D32);      // Vert principal
  static const Color primaryLight = Color(0xFF4CAF50); // Vert clair
  static const Color primaryDark = Color(0xFF1B5E20);  // Vert foncé

  // ============================================
  // 2. COULEURS SECONDAIRES (Accent)
  // ============================================
  static const Color secondary = Color(0xFFFFA726);    // Orange
  static const Color secondaryLight = Color(0xFFFFCC80); // Orange clair
  static const Color secondaryDark = Color(0xFFF57C00);  // Orange foncé

  // ============================================
  // 3. COULEURS DE STATUT
  // ============================================
  static const Color success = Color(0xFF388E3C);      // Vert (succès)
  static const Color warning = Color(0xFFFFA726);      // Orange (avertissement)
  static const Color error = Color(0xFFD32F2F);        // Rouge (erreur)
  static const Color info = Color(0xFF1976D2);         // Bleu (information)

  // ============================================
  // 4. COULEURS NEUTRES
  // ============================================
  static const Color background = Color(0xFFF5F5F5);   // Gris clair (fond)
  static const Color surface = Color(0xFFFFFFFF);      // Blanc (surfaces)
  static const Color card = Color(0xFFFFFFFF);         // Blanc (cartes)

  // ============================================
  // 5. COULEURS DE TEXTE
  // ============================================
  static const Color textPrimary = Color(0xFF212121);  // Noir (texte principal)
  static const Color textSecondary = Color(0xFF757575); // Gris (texte secondaire)
  static const Color textDisabled = Color(0xFF9E9E9E); // Gris clair (texte désactivé)

  // ============================================
  // 6. COULEURS DE BORDURES & DIVISEURS
  // ============================================
  static const Color border = Color(0xFFE0E0E0);       // Gris clair (bordures)
  static const Color divider = Color(0xFFEEEEEE);      // Très clair (diviseurs)

  // ============================================
  // 7. COULEURS SPÉCIALES (déjà utilisées dans tes widgets)
  // ============================================
  static const Color amber = Color(0xFFFFB300);        // Pour badges admin
  static const Color amberLight = Color(0xFFFFECB3);   // Fond badge admin
  static const Color shadow = Color(0x1A000000);       // Ombre (10% noir)
}