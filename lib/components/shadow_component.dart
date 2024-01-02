import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShadowComponent extends PositionComponent {
  final double borderRadius;
  final Color color;
  final double elevation;

  ShadowComponent({
    super.position,
    super.size,
    this.borderRadius = 0,
    this.color = Colors.black,
    this.elevation = 4,
    super.children,
  });

  @override
  void render(Canvas canvas) {
    const position = Offset(0, -4);

    canvas.drawShadow(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(position, size.toOffset()),
            Radius.circular(borderRadius),
          ),
        ),
      color,
      elevation,
      false,
    );

    canvas.drawShadow(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(position, size.toOffset()),
            Radius.circular(borderRadius),
          ),
        ),
      color,
      elevation,
      false,
    );
  }
}
