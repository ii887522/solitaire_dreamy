import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Card;
import '../components/card.dart';
import '../components/foundation.dart';
import '../components/foundation_pile.dart';
import '../components/stock_pile.dart';
import '../components/tableau.dart';
import '../components/tableau_pile.dart';
import '../components/waste_pile.dart';
import '../models/card_model.dart';
import '../models/foundation_pile_model.dart';
import '../models/klondike.dart';
import '../models/tableau_pile_model.dart';

class KlondikeGame extends FlameGame {
  final playingAreaKey = ComponentKey.unique();

  final _playingAreaSize = Vector2(
    Card.size_.x * 7 + Card.gap.x * 8,
    Card.size_.y * 2 + Card.gap.y * 3 + Card.stackGap.y * 18,
  );

  final model = Klondike();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final playingArea = findByKey<PositionComponent>(playingAreaKey);
    playingArea?.position = Vector2(camera.viewport.size.x * 0.5, 0);

    playingArea?.scale = Vector2.all(
      min(
        camera.viewport.size.x / _playingAreaSize.x,
        camera.viewport.size.y / _playingAreaSize.y,
      ),
    );
  }

  @override
  FutureOr<void> onLoad() async {
    // Preload audio files to avoid lagging sound
    await FlameAudio.audioCache.load('flip_card.mp3');

    model.load();
    camera.viewfinder.anchor = Anchor.topLeft;
    late final int maxStockPileCardCount;

    world.addAll([
      PositionComponent(
        key: playingAreaKey,
        anchor: Anchor.topCenter,
        size: _playingAreaSize,
        children: [
          StockPile(
            model: model.stockPile,
            onTapUp: () async {
              model.restock();
              final effectFutures = <Future<void>>[];

              for (final (i, cardModel) in model.stockPileCards.indexed) {
                final card = findByKey<Card>(cardModel.key);

                effectFutures.addAll([
                  card?.flip(),
                  card?.moveToComponent(
                    model.stockPile.key,
                    hasShadow: i == 0,
                    priority: i,
                  ),
                ].nonNulls);
              }

              await Future.wait(effectFutures);
              model.onRestocked();
            },
          ),
          WastePile(model: model.wastePile),
          Tableau(models: model.tableauPiles),
          Foundation(models: model.foundationPiles),
          for (final (i, card) in model.stockPileCards.indexed)
            Card(
              model: card,
              hasShadow: i == 0,
              onTapUp: (card) async {
                if (!model.revealCard(card.model)) return;

                await Future.wait([
                  card.flip(),
                  if (model.wastePileCards.length > 3)
                    for (var i = 0; i < 2; ++i)
                      findByKey<Card>(
                        model
                            .wastePileCards[model.wastePileCards.length - 3 + i]
                            .key,
                      )?.moveToComponent(
                        model.wastePile.key,
                        offset: Vector2(i * Card.stackGap.x, 0),
                        hasShadow: i > 0,
                      ),
                  card.moveToComponent(
                    model.wastePile.key,
                    offset: Vector2(
                      Card.stackGap.x * min(model.wastePileCards.length - 1, 2),
                      0,
                    ),
                    priority:
                        maxStockPileCardCount + model.wastePileCards.length,
                    hasShadow: true,
                  ),
                ].nonNulls);

                model.onRevealedCard(card.model);
              },
              tryStackCard: (stackedCard) async {
                return await _tryStackPile(card, stackedCard);
              },
              tryStackComponents: (stackedComponents) async {
                final stackedPile = stackedComponents
                        .whereType<TableauPile>()
                        .firstOrNull ??
                    stackedComponents.whereType<FoundationPile>().firstOrNull;

                return stackedPile != null
                    ? await _tryStackPile(card, stackedPile)
                    : false;
              },
              findStackingCards: () => model.findStackingCards(card),
            ),
        ],
      ),
      TimerComponent(
        period: 0.1,
        removeOnFinish: true,
        onTick: () async {
          // Ensure the playing area is properly sized according to the current
          // window size
          onGameResize(size);

          // Start laying out cards from the stock pile into tableau
          var i = 0;
          for (var j = 0; j < model.tableauPiles.length; ++j) {
            for (var k = j; k < model.tableauPiles.length; ++k) {
              final card = model.stockPileCards.removeLast();
              model.moveCardToTableauPile(k, card);

              await findByKey<Card>(card.key)?.moveToComponent(
                model.tableauPiles[k].key,
                offset: Vector2(0, Card.stackGap.y * j),
                priority: i,
                hasShadow: true,
              );

              ++i;
            }
          }

          maxStockPileCardCount = model.stockPileCards.length;

          // Flip bottom-most card from each tableau pile
          for (final tableauPileCards in model.tableauPilesCards) {
            tableauPileCards.last.isFaceUp = !tableauPileCards.last.isFaceUp;
            await findByKey<Card>(tableauPileCards.last.key)?.flip();
          }

          // User can start playing the game
          model.startPlaying();
        },
      ),
    ]);
  }

  Future<bool> _tryStackPile(
    CardModel stackingCard,
    PositionComponent stackedComponent,
  ) async {
    final stackedModel = switch (stackedComponent) {
      Card card => card.model,
      TableauPile tableauPile => tableauPile.model,
      FoundationPile foundationPile => foundationPile.model,
      _ => null,
    };

    if (stackedModel == null) {
      // Maybe we try to stack the card on top of the stock pile, waste pile
      // or etc which is not allowed
      return false;
    }

    final List<List<CardModel>> pilesCards;
    int dstPileIndex;

    switch (stackedModel) {
      case CardModel stackedCard: // Stack on top of the card ?

        // The stacked card belongs to the tableau pile ?
        dstPileIndex = model.tableauPiles
            .indexWhere((pile) => pile.key == stackedCard.parentKey);

        if (dstPileIndex >= 0) {
          pilesCards = model.tableauPilesCards;
        } else {
          dstPileIndex = model.foundationPiles
              .indexWhere((pile) => pile.key == stackedCard.parentKey);

          if (dstPileIndex >= 0) {
            pilesCards = model.foundationPilesCards;
          } else {
            // Maybe we try to stack the card on top of the stock pile, waste
            // pile or etc which is not allowed
            return false;
          }
        }

      case TableauPileModel stackedTableauPile:
        // Stack on top of the empty tableau pile ?
        dstPileIndex = model.tableauPiles
            .indexWhere((pile) => pile.key == stackedTableauPile.key);

        pilesCards = model.tableauPilesCards;

      case FoundationPileModel stackedFoundationPile:
        // Stack on top of the empty foundation pile ?
        dstPileIndex = model.foundationPiles
            .indexWhere((pile) => pile.key == stackedFoundationPile.key);

        pilesCards = model.foundationPilesCards;

      default:
        // Maybe we try to stack the card on top of the stock pile, waste pile
        // or etc which is not allowed
        return false;
    }

    if (!model.tryStackPile(stackingCard, stackedModel)) return false;
    final effectFutures = <Future<void>>[];
    void Function()? onEffectsDone;

    // The card is coming from the waste pile ?
    if (stackingCard.prevParentKey == model.wastePile.key) {
      if (model.wastePileCards.lastOrNull != null) {
        onEffectsDone = () => model.wastePileCards.last.isDraggable = true;
      }
    } else {
      final srcPileKeyIndex = model.tableauPiles
          .indexWhere((pile) => pile.key == stackingCard.prevParentKey);

      // The card is coming from the tableau pile ?
      if (srcPileKeyIndex >= 0) {
        final srcTableauPileCards = model.tableauPilesCards[srcPileKeyIndex];

        if (srcTableauPileCards.lastOrNull != null &&
            !srcTableauPileCards.last.prevIsFaceUp) {
          effectFutures.add(
            findByKey<Card>(srcTableauPileCards.last.key)?.flip() ??
                Future.value(),
          );

          onEffectsDone = () {
            srcTableauPileCards.last.isDraggable = true;
          };
        }

        // The card is coming from the foundation pile
        // Stack on top of the tableau pile
      } else if (pilesCards == model.tableauPilesCards) {
        model
            .foundationPilesCards[model.foundationPiles
                .indexWhere((pile) => pile.key == stackingCard.prevParentKey)]
            .lastOrNull
            ?.isDraggable = true;

        // The card is coming from the foundation pile
        // Actually stack on top of the foundation pile
      } else {
        // The stacking card is already in the foundation pile and no actions
        // should be done according to the classic Klondike game rules, so
        // considered failed to stack to return back to the previous position
        return false;
      }
    }

    effectFutures.addAll([
      if (stackingCard.prevParentKey == model.wastePile.key &&
          model.wastePileCards.length >= 3)
        for (var i = 0; i < 2; ++i)
          findByKey<Card>(
            model.wastePileCards[model.wastePileCards.length - 2 + i].key,
          )?.moveToComponent(
            model.wastePile.key,
            offset: Vector2(Card.stackGap.x * (i + 1), 0),
            hasShadow: true,
          ),
    ].nonNulls);

    // Actually stack on top of the tableau pile
    if (pilesCards == model.tableauPilesCards) {
      final dstTableauPileCardIndex =
          model.tableauPilesCards[dstPileIndex].indexOf(stackingCard);

      final stackingCards = model.tableauPilesCards[dstPileIndex].getRange(
        dstTableauPileCardIndex,
        model.tableauPilesCards[dstPileIndex].length,
      );

      effectFutures.addAll([
        for (final (i, stackingCard) in stackingCards.indexed)
          findByKey<Card>(stackingCard.key)?.moveToComponent(
            model.tableauPiles[dstPileIndex].key,
            offset: Vector2(0, Card.stackGap.y * (dstTableauPileCardIndex + i)),
            priority: stackedComponent.priority + 1 + i,
            hasShadow: true,
          ),
      ].nonNulls);

      // Actually stack on top of the foundation pile
    } else {
      effectFutures.add(
        findByKey<Card>(stackingCard.key)?.moveToComponent(
              model.foundationPiles[dstPileIndex].key,
              hasShadow: model.foundationPilesCards[dstPileIndex].length == 1,
              priority: stackedComponent.priority + 1,
            ) ??
            Future.value(),
      );
    }

    await Future.wait(effectFutures);
    onEffectsDone?.call();
    return true;
  }

  @override
  void onRemove() async => await FlameAudio.audioCache.clearAll();
}
