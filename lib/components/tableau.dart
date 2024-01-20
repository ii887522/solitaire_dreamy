import 'dart:async';
import 'package:flame/components.dart';
import '../models/tableau_pile_model.dart';
import 'card.dart';
import 'tableau_pile.dart';

class Tableau extends PositionComponent {
  final List<TableauPileModel> models;

  Tableau({required this.models})
      : super(
          position: Vector2(Card.gap.x, Card.size_.y + Card.gap.y * 2),
          size: Vector2(Card.size_.x * 7 + Card.gap.x * 6, Card.size_.y),
        );

  @override
  FutureOr<void> onLoad() {
    addAll([
      for (final (i, model) in models.indexed)
        TableauPile(
          position: Vector2((Card.size_.x + Card.gap.x) * i, 0),
          model: model,
        ),
    ]);
  }
}
