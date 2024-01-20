import 'package:flame/components.dart';
import 'card_model.dart';
import 'rank.dart';

class TableauPileModel {
  final key = ComponentKey.unique();

  static bool isStackableBy(CardModel stackingCard) {
    // Follow the classic Klondike game rules
    return stackingCard.rank.value == Rank.max;
  }

  static bool isStackable(CardModel stackingCard, CardModel stackedCard) {
    // Follow the classic Klondike game rules
    return stackingCard.suit.toColor() != stackedCard.suit.toColor() &&
        stackingCard.rank.value + 1 == stackedCard.rank.value;
  }
}
