import 'extensions/platform_ext.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformExt.isDesktop) {
    await windowManager.ensureInitialized();

    windowManager.waitUntilReadyToShow(
      const WindowOptions(
        center: true,
        minimumSize: Size(320, 461),
        size: Size(533, 768),
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  await Flame.device.setPortrait();
  runApp(const App());
}
