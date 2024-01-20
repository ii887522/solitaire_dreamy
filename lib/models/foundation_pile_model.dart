import 'package:flame/components.dart';
import 'card_model.dart';
import 'rank.dart';
import 'suit.dart';

class FoundationPileModel {
  final key = ComponentKey.unique();
  final Suit suit;

  FoundationPileModel({required this.suit});

  static bool isStackable(
    CardModel stackingCard,
    CardModel stackedCard,
  ) {
    // Follow the classic Klondike game rules
    return stackingCard.suit == stackedCard.suit &&
        stackingCard.rank.value - 1 == stackedCard.rank.value;
  }

  bool isStackableBy(CardModel stackingCard) {
    // Follow the classic Klondike game rules
    return stackingCard.suit == suit && stackingCard.rank.value == Rank.min;
  }
}
