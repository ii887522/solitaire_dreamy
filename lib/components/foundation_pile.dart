import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import '../models/card_model.dart';
import '../models/rank.dart';
import '../models/suit.dart';
import 'card.dart';

class FoundationPile extends PositionComponent {
  final ComponentKey key;
  final Suit suit;

  FoundationPile({required this.key, super.position, required this.suit})
      : super(key: key, size: Card.size_);

  static bool isStackable(
    CardModel stackingCardModel,
    CardModel stackedCardModel,
  ) {
    // Follow the classic Klondike game rules
    return stackingCardModel.suit == stackedCardModel.suit &&
        stackingCardModel.rank.value - 1 == stackedCardModel.rank.value;
  }

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
      SvgComponent(
        svg: await suit.toSvg(),
        anchor: Anchor.center,
        position: size * 0.5,
        size: Vector2.all(40),
        paint: cardPlaceholderSvgPaint,
      ),
    ]);
  }

  bool isStackableBy(CardModel stackingCardModel) {
    // Follow the classic Klondike game rules
    return stackingCardModel.suit == suit &&
        stackingCardModel.rank.value == Rank.min;
  }
}
