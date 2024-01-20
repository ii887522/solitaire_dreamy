import 'dart:async';
import 'package:flame/components.dart';
import '../consts/index.dart';
import '../models/waste_pile_model.dart';
import 'card.dart';

class WastePile extends PositionComponent {
  WastePile({required WastePileModel model})
      : super(
          key: model.key,
          position: Vector2(Card.size_.x + Card.gap.x * 2, Card.gap.y),
          size: Card.size_,
        );

  @override
  FutureOr<void> onLoad() async {
    add(
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
    );
  }
}
