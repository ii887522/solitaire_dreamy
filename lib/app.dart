import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/pages/klondike_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitaire Dreamy',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
      home: const KlondikePage(),
    );
  }
}
