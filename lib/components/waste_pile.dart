import 'dart:async';
import 'package:flame/components.dart';
import '../consts/index.dart';
import 'card.dart';

class WastePile extends PositionComponent {
  WastePile({super.key})
      : super(
          position: Vector2(Card.size_.x + Card.gap.x * 2, Card.gap.y),
          size: Card.size_,
        );

  @override
  FutureOr<void> onLoad() async {
    add(
      RectangleComponent(
        size: Card.size_,
        paint: cardPlaceholderBorderPaint,
      ),
    );
  }
}
