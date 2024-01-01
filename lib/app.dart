import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/pages/klondike_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitaire Dreamy',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme.of(context).copyWith(
          elevation: 6,
          shadowColor: Colors.black,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF86468B),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFFFD6FC),
          onPrimaryContainer: Color(0xFF36003E),
          secondary: Color(0xFF86468C),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFFD6FD),
          onSecondaryContainer: Color(0xFF36003E),
          tertiary: Color(0xFF825249),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFFFDAD4),
          onTertiaryContainer: Color(0xFF33110B),
          error: Color(0xFFBA1A1A),
          errorContainer: Color(0xFFFFDAD6),
          onError: Color(0xFFFFFFFF),
          onErrorContainer: Color(0xFF410002),
          background: Color(0xFFFFFBFF),
          onBackground: Color(0xFF1E1A1D),
          surface: Color(0xFFFFFBFF),
          onSurface: Color(0xFF1E1A1D),
          surfaceVariant: Color(0xFFEDDFE8),
          onSurfaceVariant: Color(0xFF4D444C),
          outline: Color(0xFF7F747C),
          onInverseSurface: Color(0xFFF7EEF2),
          inverseSurface: Color(0xFF332F32),
          inversePrimary: Color(0xFFF8ACFB),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFF86468B),
          outlineVariant: Color(0xFFD0C3CC),
          scrim: Color(0xFF000000),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme.of(context).copyWith(
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFF8ACFB),
          onPrimary: Color(0xFF511459),
          primaryContainer: Color(0xFF6B2D72),
          onPrimaryContainer: Color(0xFFFFD6FC),
          secondary: Color(0xFFF8ADFB),
          onSecondary: Color(0xFF51145A),
          secondaryContainer: Color(0xFF6B2D72),
          onSecondaryContainer: Color(0xFFFFD6FD),
          tertiary: Color(0xFFF6B8AC),
          onTertiary: Color(0xFF4C251E),
          tertiaryContainer: Color(0xFF673B33),
          onTertiaryContainer: Color(0xFFFFDAD4),
          error: Color(0xFFFFB4AB),
          errorContainer: Color(0xFF93000A),
          onError: Color(0xFF690005),
          onErrorContainer: Color(0xFFFFDAD6),
          background: Color(0xFF1E1A1D),
          onBackground: Color(0xFFE9E0E4),
          surface: Color(0xFF1E1A1D),
          onSurface: Color(0xFFE9E0E4),
          surfaceVariant: Color(0xFF4D444C),
          onSurfaceVariant: Color(0xFFD0C3CC),
          outline: Color(0xFF998D96),
          onInverseSurface: Color(0xFF1E1A1D),
          inverseSurface: Color(0xFFE9E0E4),
          inversePrimary: Color(0xFF86468B),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFFF8ACFB),
          outlineVariant: Color(0xFF4D444C),
          scrim: Color(0xFF000000),
        ),
      ),
      home: const KlondikePage(),
    );
  }
}
