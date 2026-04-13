import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF63A4FF);
  
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF6EC6FF);
  
  static const Color accent = Color(0xFFFF6B6B);
  
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  
  static const Color iconPrimary = Color(0xFF1976D2);
  static const Color iconSecondary = Color(0xFF757575);
  
  static const Color shadow = Color(0x1A000000);
  
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = Color(0xFF1976D2);
  
  static const Color buttonPrimary = Color(0xFF1976D2);
  static const Color buttonSecondary = Color(0xFFE3F2FD);
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusInactive = Color(0xFFE0E0E0);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusCompleted = Color(0xFF4CAF50);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
