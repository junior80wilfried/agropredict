import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typographie de la maquette : Playfair Display (titres) + Nunito (texte).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle serif({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle sans({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
