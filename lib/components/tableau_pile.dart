import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Card;
import '../consts/index.dart';
import '../extensions/platform_ext.dart';
import '../models/tableau_pile_model.dart';
import 'card.dart';

class TableauPile extends PositionComponent {
  final TableauPileModel model;

  TableauPile({required this.model, super.position})
      : super(key: model.key, size: Card.size_);

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
