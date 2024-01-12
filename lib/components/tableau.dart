import 'dart:async';
import 'package:flame/components.dart';
import 'card.dart';
import 'tableau_pile.dart';

class Tableau extends PositionComponent {
  final List<ComponentKey> pileKeys;

  Tableau({required this.pileKeys})
      : super(
          position: Vector2(Card.gap.x, Card.size_.y + Card.gap.y * 2),
          size: Vector2(Card.size_.x * 7 + Card.gap.x * 6, Card.size_.y),
        );

  @override
  FutureOr<void> onLoad() {
    addAll([
      for (final (i, pileKey) in pileKeys.indexed)
        TableauPile(
          key: pileKey,
          position: Vector2((Card.size_.x + Card.gap.x) * i, 0),
        ),
    ]);
  }
}
