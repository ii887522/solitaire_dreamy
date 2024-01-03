import 'dart:async';
import 'package:flame/components.dart';
import 'package:solitaire_dreamy/components/tableau_pile.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class Tableau extends PositionComponent {
  Tableau()
      : super(position: beginCardGap + Vector2(0, cardSize.y + cardGap.y));

  @override
  FutureOr<void> onLoad() {
    addAll([
      TableauPile(),
      TableauPile(position: Vector2(cardSize.x + cardGap.x, 0)),
      TableauPile(position: Vector2(cardSize.x * 2 + cardGap.x * 2, 0)),
      TableauPile(position: Vector2(cardSize.x * 3 + cardGap.x * 3, 0)),
      TableauPile(position: Vector2(cardSize.x * 4 + cardGap.x * 4, 0)),
      TableauPile(position: Vector2(cardSize.x * 5 + cardGap.x * 5, 0)),
      TableauPile(position: Vector2(cardSize.x * 6 + cardGap.x * 6, 0)),
    ]);
  }
}
