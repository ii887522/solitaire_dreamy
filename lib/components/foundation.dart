import 'dart:async';
import 'package:flame/components.dart';
import 'package:solitaire_dreamy/components/foundation_pile.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class Foundation extends PositionComponent {
  Foundation() : super(position: beginCardGap);

  @override
  FutureOr<void> onLoad() {
    addAll([
      FoundationPile(
        position: Vector2(cardSize.x * 3 + cardGap.x * 3, 0),
        suitIconFileName: 'icons/spade.svg',
      ),
      FoundationPile(
        position: Vector2(cardSize.x * 4 + cardGap.x * 4, 0),
        suitIconFileName: 'icons/heart.svg',
      ),
      FoundationPile(
        position: Vector2(cardSize.x * 5 + cardGap.x * 5, 0),
        suitIconFileName: 'icons/club.svg',
      ),
      FoundationPile(
        position: Vector2(cardSize.x * 6 + cardGap.x * 6, 0),
        suitIconFileName: 'icons/diamond.svg',
      ),
    ]);
  }
}
