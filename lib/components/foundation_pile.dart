import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import '../models/card_model.dart';
import '../models/rank.dart';
import '../models/suit.dart';
import 'card.dart';

class FoundationPile extends PositionComponent {
  final Suit suit;

  FoundationPile({super.position, required this.suit})
      : super(size: Card.size_);

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
