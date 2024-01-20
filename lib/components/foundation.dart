import 'dart:async';
import 'package:flame/components.dart';
import '../models/foundation_pile_model.dart';
import 'card.dart';
import 'foundation_pile.dart';

class Foundation extends PositionComponent {
  final List<FoundationPileModel> models;

  Foundation({required this.models})
      : super(
          position: Vector2(Card.size_.x * 3 + Card.gap.x * 4, Card.gap.y),
          size: Vector2(Card.size_.x * 4 + Card.gap.x * 3, Card.gap.y),
        );

  @override
  FutureOr<void> onLoad() {
    addAll([
      for (final (i, model) in models.indexed)
        FoundationPile(
          position: Vector2((Card.size_.x + Card.gap.x) * i, 0),
          model: model,
        ),
    ]);
  }
}
