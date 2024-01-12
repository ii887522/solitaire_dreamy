import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Card;

class ShadowComponent extends PositionComponent {
  final double cornerRadius;
  bool isEnabled;

  ShadowComponent({
    super.key,
    super.size,
    this.cornerRadius = 0,
    this.isEnabled = false,
    super.children,
  });

  @override
  void render(Canvas canvas) {
    if (!isEnabled) return;

    canvas.drawShadow(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              const Offset(-2, -3),
              size.toOffset() + const Offset(1.5, 1),
            ),
            Radius.circular(cornerRadius),
          ),
        ),
      Colors.black,
      3,
      false,
    );
  }
}
