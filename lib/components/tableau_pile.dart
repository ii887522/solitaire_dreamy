import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Card;
import '../consts/index.dart';
import '../extensions/platform_ext.dart';
import 'card.dart';

class TableauPile extends PositionComponent {
  TableauPile({super.key, super.position}) : super(size: Card.size_);

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
      TextComponent(
        text: 'K',
        anchor: Anchor.center,
        position: Card.size_ * 0.5 -
            (PlatformExt.isMobile ? Vector2.zero() : Vector2(0, 2)),
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 48, color: cardPlaceholderColor),
        ),
      ),
    ]);
  }
}
