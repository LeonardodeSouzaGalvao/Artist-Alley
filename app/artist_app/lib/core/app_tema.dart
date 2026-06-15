import 'package:flutter/material.dart';
import 'app_cores.dart';

class AppTema {
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: false,
      primaryColor: AppCores.corPrimaria,
      colorScheme: const ColorScheme.light(
        primary: AppCores.corPrimaria,
        onPrimary: AppCores.corTextoBranco,
        secondary: AppCores.corPrimaria,
        onSecondary: AppCores.corTextoBranco,
        surface: AppCores.corFundo,
        onSurface: AppCores.corTexto,
      ),
      scaffoldBackgroundColor: AppCores.corFundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppCores.corSecundaria,
        foregroundColor: AppCores.corTexto,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppCores.corTexto,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppCores.corPrimaria,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCores.corPrimaria,
          foregroundColor: AppCores.corTextoBranco,
          disabledBackgroundColor: AppCores.corPrimaria.withOpacity(0.4),
          disabledForegroundColor: AppCores.corTextoBranco.withOpacity(0.7),
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppCores.corSecundaria,
        selectedItemColor: AppCores.corPrimaria,
        unselectedItemColor: AppCores.corTextoClaro,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppCores.corSecundaria,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppCores.corBorda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppCores.corBorda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppCores.corPrimaria, width: 2),
        ),
        hintStyle: const TextStyle(color: AppCores.corTextoClaro),
        labelStyle: const TextStyle(color: AppCores.corTextoSecundario),
      ),
      cardTheme: CardThemeData(
        color: AppCores.corFundoCard,
        elevation: 2,
        shadowColor: AppCores.corSombra,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppCores.corBorda, width: 0.5),
        ),
      ),
      dividerColor: AppCores.corDivisor,
      fontFamily: 'Roboto',
    );
  }
}