import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solitaire_dreamy/app.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    windowManager.waitUntilReadyToShow(
      const WindowOptions(
        center: true,
        minimumSize: Size(320, 500),
        size: Size(461, 720),
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}
