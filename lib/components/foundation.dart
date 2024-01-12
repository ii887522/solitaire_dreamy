import 'dart:async';
import 'package:flame/components.dart';
import 'card.dart';
import 'foundation_pile.dart';

class Foundation extends PositionComponent {
  Foundation()
      : super(
          position: Vector2(Card.size_.x * 3 + Card.gap.x * 4, Card.gap.y),
          size: Vector2(Card.size_.x * 4 + Card.gap.x * 3, Card.gap.y),
        );

  @override
  FutureOr<void> onLoad() {
    addAll([
      for (final (i, iconFileName) in [
        'icons/spade.svg',
        'icons/heart.svg',
        'icons/club.svg',
        'icons/diamond.svg',
      ].indexed)
        FoundationPile(
          position: Vector2((Card.size_.x + Card.gap.x) * i, 0),
          iconFileName: iconFileName,
        ),
    ]);
  }
}
