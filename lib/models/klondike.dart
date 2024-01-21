import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../consts/index.dart';
import 'card_model.dart';
import 'foundation_pile_model.dart';
import 'rank.dart';
import 'stock_pile_model.dart';
import 'suit.dart';
import 'tableau_pile_model.dart';
import 'waste_pile_model.dart';

class Klondike {
  // Stock pile
  final stockPile = StockPileModel();
  var stockPileCards = <CardModel>[];

  // Waste pile
  final wastePile = WastePileModel();
  var wastePileCards = <CardModel>[];

  // Tableau piles
  final tableauPiles = [
    for (var i = 0; i < tableauPileCount; ++i) TableauPileModel()
  ];

  final tableauPilesCards = [
    for (var i = 0; i < tableauPileCount; ++i) <CardModel>[]
  ];

  // Foundation piles
  final foundationPiles = [
    for (final suit in Suit.values) FoundationPileModel(suit: suit)
  ];

  final foundationPilesCards = [for (final _ in Suit.values) <CardModel>[]];

  // User events
  var isDraggingCard = false;

  void load() {
    // Prepare a standard 52-card deck
    stockPileCards = [
      for (final suit in Suit.values)
        for (var rank = Rank.min; rank <= Rank.max; ++rank)
          CardModel(
            suit: suit,
            rank: Rank(rank),
            parentKey: stockPile.key,
            game: this,
          )
    ]..shuffle();
  }

  void moveCardToTableauPile(int tableauPileIndex, CardModel card) {
    tableauPilesCards[tableauPileIndex].add(card);
    card.parentKey = tableauPiles[tableauPileIndex].key;
  }

  void startPlaying() {
    stockPileCards.last.isClickable = true;

    for (final tableauPileCards in tableauPilesCards) {
      tableauPileCards.last.isDraggable = true;
    }
  }

  void restock() {
    stockPile.isClickable = false;

    // Restock the stock pile from the waste pile
    wastePileCards.reverse();
    stockPileCards = wastePileCards;
    wastePileCards = [];

    for (final card in stockPileCards) {
      card.isClickable = false;
      card.isDraggable = false;
      card.parentKey = stockPile.key;
      card.isFaceUp = !card.isFaceUp;
    }
  }

  void onRestocked() {
    if (stockPileCards.lastOrNull != null) {
      stockPileCards.last.isClickable = true;
    }
  }

  bool revealCard(CardModel card) {
    if (card.parentKey != stockPile.key) return false;

    // This waste pile card is not draggable due to partially covered by a new
    // card in the waste pile later
    if (wastePileCards.lastOrNull != null) {
      wastePileCards.last.isDraggable = false;
    }

    // Top-most card from the stock pile reveals to the waste pile
    wastePileCards.add(stockPileCards.removeLast());
    card.parentKey = wastePile.key;
    card.isFaceUp = !card.isFaceUp;

    return true;
  }

  void onRevealedCard(CardModel card) {
    // User can drag the top-most card in the waste pile
    card.isDraggable = true;

    if (stockPileCards.lastOrNull != null) {
      stockPileCards.last.isClickable = true;
    } else {
      stockPile.isClickable = true;
    }
  }

  bool tryStackPile(CardModel stackingCard, Object stackedModel) {
    final List<List<CardModel>> pilesCards;
    final int dstPileKeyIndex;

    switch (stackedModel) {
      case CardModel stackedCard: // Stack on top of the card ?
        final List<ComponentKey> pileKeys;

        final bool Function(
          CardModel stackingCard,
          CardModel stackedCard,
        ) isStackable;

        final tableauPileKeys = tableauPiles.map((pile) => pile.key).toList();

        // The stacked card belongs to the tableau pile ?
        if (tableauPileKeys.contains(stackedCard.parentKey)) {
          pileKeys = tableauPileKeys;
          pilesCards = tableauPilesCards;
          isStackable = TableauPileModel.isStackable;
        } else {
          final foundationPileKeys =
              foundationPiles.map((pile) => pile.key).toList();

          // The stacked card belongs to the foundation pile ?
          if (foundationPileKeys.contains(stackedCard.parentKey)) {
            pileKeys = foundationPileKeys;
            pilesCards = foundationPilesCards;
            isStackable = FoundationPileModel.isStackable;

            // Maybe we try to stack the card on top of the stock pile, waste
            // pile or etc which is not allowed
          } else {
            return false;
          }
        }

        dstPileKeyIndex = pileKeys.indexOf(stackedCard.parentKey);

        // Only can stack on top of the bottom-most card in the tableau pile or
        // top-most card in the foundation pile
        if (dstPileKeyIndex < 0 ||
            stackedCard.key != pilesCards[dstPileKeyIndex].last.key) {
          return false;
        }

        // Is stackable according to the classic Klondike game rules ?
        if (!isStackable(stackingCard, stackedCard)) return false;

      case TableauPileModel stackedTableauPile:
        // Stack on top of the empty tableau pile ?
        // Is stackable according to the classic Klondike game rules ?
        if (!TableauPileModel.isStackableBy(stackingCard)) return false;

        dstPileKeyIndex = tableauPiles
            .indexWhere((pile) => pile.key == stackedTableauPile.key);

        pilesCards = tableauPilesCards;

      case FoundationPileModel stackedFoundationPile:
        // Stack on top of the empty foundation pile ?
        // Is stackable according to the classic Klondike game rules ?
        if (!stackedFoundationPile.isStackableBy(stackingCard)) return false;

        dstPileKeyIndex = foundationPiles
            .indexWhere((pile) => pile.key == stackedFoundationPile.key);

        pilesCards = foundationPilesCards;

      default:
        // Maybe we try to stack the card on top of the stock pile, waste pile
        // or etc which is not allowed
        return false;
    }

    // The card is coming from the waste pile ?
    if (stackingCard.parentKey == wastePile.key) {
      // Only the top-most waste pile card can be removed. So can assume always
      // remove the last card key
      pilesCards[dstPileKeyIndex].add(wastePileCards.removeLast());

      // The card is coming from the tableau pile ?
    } else {
      final srcPileKeyIndex =
          tableauPiles.indexWhere((pile) => pile.key == stackingCard.parentKey);

      if (srcPileKeyIndex >= 0) {
        final srcTableauPileCards = tableauPilesCards[srcPileKeyIndex];

        final srcTableauPileCardIndex =
            srcTableauPileCards.indexOf(stackingCard);

        // Stack on top of the tableau pile
        if (pilesCards == tableauPilesCards) {
          // Move the bottom section of cards between tableau piles
          if (srcPileKeyIndex != dstPileKeyIndex) {
            tableauPilesCards[dstPileKeyIndex].addAll(
              srcTableauPileCards.getRange(
                srcTableauPileCardIndex,
                srcTableauPileCards.length,
              ),
            );

            srcTableauPileCards.removeRange(
              srcTableauPileCardIndex,
              srcTableauPileCards.length,
            );
          }

          // Stack on top of the foundation pile
        } else {
          if (srcTableauPileCardIndex < srcTableauPileCards.length - 1) {
            // Cannot stack multiple cards on top of the foundation pile
            // according to the classic Klondike game rules
            return false;
          }

          // Only the bottom-most tableau pile card can be removed. So can assume
          // always remove the last card key.
          foundationPilesCards[dstPileKeyIndex].add(
            srcTableauPileCards.removeLast(),
          );
        }

        // Reveal the next bottom-most card in the tableau pile
        srcTableauPileCards.lastOrNull?.isFaceUp = true;

        // The card is coming from the foundation pile
        // Stack on top of the tableau pile
      } else if (pilesCards == tableauPilesCards) {
        // Move the card back to the tableau pile.
        final srcFoundationPileCards = foundationPilesCards[foundationPiles
            .indexWhere((pile) => pile.key == stackingCard.parentKey)];

        // Only the top-most foundation pile card can be removed. So can assume
        // always remove the last card key.
        tableauPilesCards[dstPileKeyIndex].add(
          srcFoundationPileCards.removeLast(),
        );

        // The card is coming from the foundation pile
        // Stack on top of the foundation pile
      } else {
        // The stacking card is already in the foundation pile and no actions
        // should be done according to the classic Klondike game rules, so
        // considered failed to stack to return back to the previous position
        return false;
      }
    }

    // Actually stack on top of the tableau pile
    if (pilesCards == tableauPilesCards) {
      final dstTableauPileCardIndex =
          tableauPilesCards[dstPileKeyIndex].indexOf(stackingCard);

      final stackingCards = tableauPilesCards[dstPileKeyIndex].getRange(
        dstTableauPileCardIndex,
        tableauPilesCards[dstPileKeyIndex].length,
      );

      for (final stackingCard in stackingCards) {
        stackingCard.parentKey = tableauPiles[dstPileKeyIndex].key;
      }

      // Actually stack on top of the foundation pile
    } else {
      if (stackedModel is CardModel) stackedModel.isDraggable = false;
      stackingCard.parentKey = foundationPiles[dstPileKeyIndex].key;
    }

    return true;
  }

  List<CardModel> findStackingCards(CardModel card) {
    final tableauPileIndex =
        tableauPiles.indexWhere((pile) => pile.key == card.parentKey);

    // The card is dragged from the waste pile and should not have
    // any stacking cards following this card.
    if (tableauPileIndex < 0) return [card];

    return tableauPilesCards[tableauPileIndex]
        .getRange(
          tableauPilesCards[tableauPileIndex].indexOf(card),
          tableauPilesCards[tableauPileIndex].length,
        )
        .toList();
  }
}
