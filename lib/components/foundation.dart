import 'dart:async';
import 'package:flame/components.dart';
import '../models/suit.dart';
import 'card.dart';
import 'foundation_pile.dart';

class Foundation extends PositionComponent {
  final List<ComponentKey> pileKeys;

  Foundation({required this.pileKeys})
      : super(
          position: Vector2(Card.size_.x * 3 + Card.gap.x * 4, Card.gap.y),
          size: Vector2(Card.size_.x * 4 + Card.gap.x * 3, Card.gap.y),
        );

  @override
  FutureOr<void> onLoad() {
    addAll([
      for (final (i, suit) in Suit.values.indexed)
        FoundationPile(
          key: pileKeys[i],
          position: Vector2((Card.size_.x + Card.gap.x) * i, 0),
          suit: suit,
        ),
    ]);
  }
}
