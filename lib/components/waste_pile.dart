import 'dart:async';
import 'package:flame/components.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class WastePile extends PositionComponent {
  WastePile()
      : super(
          position: beginCardGap +
              Vector2(cardSize.x + cardGap.x, 0) +
              cardPlaceholderPositionOffset,
          size: cardSize + cardPlaceholderSizeOffset,
        );

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleComponent(
        size: cardSize + cardPlaceholderSizeOffset,
        paint: cardPlaceholderPaint,
      ),
    );
  }
}
