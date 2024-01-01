import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class KlondikeGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  FutureOr<void> onLoad() {
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}
