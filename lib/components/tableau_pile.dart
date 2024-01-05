import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class TableauPile extends PositionComponent {
  TableauPile({super.position})
      : super(size: cardSize + cardPlaceholderSizeOffset);

  @override
  FutureOr<void> onLoad() {
    addAll([
      RectangleComponent(
        position: cardPlaceholderPositionOffset,
        size: cardSize + cardPlaceholderSizeOffset,
        paint: cardPlaceholderPaint,
      ),
      TextComponent(
        text: 'K',
        anchor: Anchor.center,
        position: cardSize * 0.5,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 48, color: Color(0xFF804080)),
        ),
      ),
    ]);
  }
}
