import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Card;
import '../components/card.dart';
import '../components/foundation.dart';
import '../components/stock_pile.dart';
import '../components/tableau.dart';
import '../components/waste_pile.dart';
import '../models/card_model.dart';
import '../models/rank.dart';
import '../models/suit.dart';

class KlondikeGame extends FlameGame {
  final playingAreaKey = ComponentKey.unique();

  final _playingAreaSize = Vector2(
    Card.size_.x * 7 + Card.gap.x * 8,
    Card.size_.y * 2 + Card.gap.y * 3 + Card.stackGap.y * 18,
  );

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
    camera.viewfinder.anchor = Anchor.topLeft;
    final stockPileKey = ComponentKey.unique();

    // Prepare a standard 52-card deck
    final cardModels = [
      for (final suit in Suit.values)
        for (var rank = Rank.min; rank <= Rank.max; ++rank)
          CardModel(suit: suit, rank: Rank(rank), parentKey: stockPileKey)
    ];

    final random = Random(0); // TODO: For testing purpose
    cardModels.shuffle(random);

    var stockPileCardKeys = [for (final _ in cardModels) ComponentKey.unique()];
    final wastePileKey = ComponentKey.unique();
    var wastePileCardKeys = <ComponentKey>[];
    final tableauPileKeys = [for (var i = 0; i < 7; ++i) ComponentKey.unique()];

    final tableauPilesCardKeys = [
      for (final _ in tableauPileKeys) <ComponentKey>[]
    ];

    late final int maxStockPileCardCount;

    world.addAll([
      PositionComponent(
        key: playingAreaKey,
        anchor: Anchor.topCenter,
        position: Vector2(camera.viewport.size.x * 0.5, 0),
        size: _playingAreaSize,
        children: [
          StockPile(
            key: stockPileKey,
            onTapUp: (stockPile) async {
              stockPile.isClickable = false;

              // Restock the stock pile from the waste pile
              wastePileCardKeys.reverse();
              stockPileCardKeys = wastePileCardKeys;
              wastePileCardKeys = [];
              final effectFutures = <Future<void>>[];

              for (final (i, cardKey) in stockPileCardKeys.indexed) {
                final card = findByKey<Card>(cardKey);
                card?.model.parentKey = stockPileKey;
                card?.model.isClickable = false;

                effectFutures.addAll([
                  card?.flip(),
                  card?.moveToComponent(
                    stockPileKey,
                    hasShadow: i == 0,
                    priority: i,
                  ),
                ].nonNulls);
              }

              await Future.wait(effectFutures);
              findByKey<Card>(stockPileCardKeys.last)?.model.isClickable = true;
            },
          ),
          WastePile(key: wastePileKey),
          Foundation(),
          Tableau(pileKeys: tableauPileKeys),
          for (final (i, cardKey) in stockPileCardKeys.indexed)
            Card(
              key: cardKey,
              model: cardModels.removeLast(),
              hasShadow: i == 0,
              onTapUp: (card) async {
                if (card.model.parentKey != stockPileKey) return;

                // This waste pile card is not draggable due to partially
                // covered by a new card in the waste pile later
                if (wastePileCardKeys.lastOrNull != null) {
                  findByKey<Card>(wastePileCardKeys.last)?.model.isDraggable =
                      false;
                }

                // Top-most card from the stock pile reveals to the waste pile
                wastePileCardKeys.add(stockPileCardKeys.removeLast());
                card.model.parentKey = wastePileKey;

                await Future.wait([
                  card.flip(),
                  if (wastePileCardKeys.length > 3)
                    for (var i = 0; i < 2; ++i)
                      findByKey<Card>(
                            wastePileCardKeys[wastePileCardKeys.length - 3 + i],
                          )?.moveToComponent(
                            wastePileKey,
                            offset: Vector2(i * Card.stackGap.x, 0),
                            hasShadow: i > 0,
                          ) ??
                          Future.value(),
                  card.moveToComponent(
                    wastePileKey,
                    offset: Vector2(
                      Card.stackGap.x * (min(wastePileCardKeys.length - 1, 2)),
                      0,
                    ),
                    priority: maxStockPileCardCount + wastePileCardKeys.length,
                  ),
                ]);

                // User can drag the top-most card in the waste pile
                card.model.isDraggable = true;

                final stockPileCardKey = stockPileCardKeys.lastOrNull;

                if (stockPileCardKey != null) {
                  findByKey<Card>(stockPileCardKey)?.model.isClickable = true;
                } else {
                  findByKey<StockPile>(stockPileKey)?.isClickable = true;
                }
              },
              tryStack: (stackedCard) async {
                final dstTableauPileKeyIndex =
                    tableauPileKeys.indexOf(stackedCard.model.parentKey);

                // Only can stack on top of the bottom-most card in the tableau
                // pile
                if (dstTableauPileKeyIndex < 0 ||
                    stackedCard.key !=
                        tableauPilesCardKeys[dstTableauPileKeyIndex].last) {
                  return false;
                }

                final card = findByKey<Card>(cardKey);

                // The card must exist, otherwise probably programming errors.
                if (card == null) return false;

                // Is stackable according to the classic Klondike game rules ?
                if (!card.model.isStackable(stackedCard.model)) return false;

                final effectFutures = <Future<void>>[];
                void Function()? onEffectsDone;

                // The card is coming from the waste pile ?
                if (card.model.parentKey == wastePileKey) {
                  // Only the top-most waste pile card can be removed. So can
                  // assume always remove the last card key
                  tableauPilesCardKeys[dstTableauPileKeyIndex]
                      .add(wastePileCardKeys.removeLast());

                  if (wastePileCardKeys.lastOrNull != null) {
                    onEffectsDone = () {
                      findByKey<Card>(wastePileCardKeys.last)
                          ?.model
                          .isDraggable = true;
                    };
                  }
                } else {
                  // The card is coming from the tableau pile
                  final srcTableauPileCardKeys = tableauPilesCardKeys[
                      tableauPileKeys.indexOf(card.model.parentKey)];

                  // Move the bottom section of cards between tableau piles
                  final srcTableauPileCardKeyIndex =
                      srcTableauPileCardKeys.indexOf(cardKey);

                  tableauPilesCardKeys[dstTableauPileKeyIndex].addAll(
                    srcTableauPileCardKeys.getRange(
                      srcTableauPileCardKeyIndex,
                      srcTableauPileCardKeys.length,
                    ),
                  );

                  srcTableauPileCardKeys.removeRange(
                    srcTableauPileCardKeyIndex,
                    srcTableauPileCardKeys.length,
                  );

                  if (srcTableauPileCardKeys.lastOrNull != null) {
                    final lastSrcTableauPileCard =
                        findByKey<Card>(srcTableauPileCardKeys.last);

                    if (lastSrcTableauPileCard?.model.isFaceUp == false) {
                      // Reveal the next bottom-most card in the tableau pile
                      effectFutures.add(
                        lastSrcTableauPileCard?.flip() ?? Future.value(),
                      );

                      onEffectsDone = () {
                        lastSrcTableauPileCard?.model.isDraggable = true;
                      };
                    }
                  }
                }

                final dstTableauPileCardKeyIndex =
                    tableauPilesCardKeys[dstTableauPileKeyIndex]
                        .indexOf(cardKey);

                final cardKeys =
                    tableauPilesCardKeys[dstTableauPileKeyIndex].getRange(
                  dstTableauPileCardKeyIndex,
                  tableauPilesCardKeys[dstTableauPileKeyIndex].length,
                );

                effectFutures.addAll([
                  if (card.model.parentKey == wastePileKey &&
                      wastePileCardKeys.length >= 3)
                    for (var i = 0; i < 2; ++i)
                      findByKey<Card>(
                        wastePileCardKeys[wastePileCardKeys.length - 2 + i],
                      )?.moveToComponent(
                        wastePileKey,
                        offset: Vector2(Card.stackGap.x * (i + 1), 0),
                      ),
                  for (final (i, cardKey) in cardKeys.indexed)
                    findByKey<Card>(cardKey)?.moveToComponent(
                      tableauPileKeys[dstTableauPileKeyIndex],
                      offset: Vector2(
                        0,
                        Card.stackGap.y * (dstTableauPileCardKeyIndex + i),
                      ),
                      priority: stackedCard.priority + 1,
                    ),
                ].nonNulls);

                for (final cardKey in cardKeys) {
                  findByKey<Card>(cardKey)?.model.parentKey =
                      tableauPileKeys[dstTableauPileKeyIndex];
                }

                await Future.wait(effectFutures);
                onEffectsDone?.call();
                return true;
              },
              findStackingCardKeys: () {
                final card = findByKey<Card>(cardKey);

                // The card must exist, otherwise probably programming errors.
                if (card == null) return [cardKey];

                final tableauPileKeyIndex = tableauPileKeys.indexOf(
                  card.model.parentKey,
                );

                // The card is dragged from the waste pile and should not have
                // any stacking cards following this card.
                if (tableauPileKeyIndex < 0) return [cardKey];

                return tableauPilesCardKeys[tableauPileKeyIndex]
                    .getRange(
                      tableauPilesCardKeys[tableauPileKeyIndex]
                          .indexOf(cardKey),
                      tableauPilesCardKeys[tableauPileKeyIndex].length,
                    )
                    .toList();
              },
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
          for (var j = 0; j < tableauPileKeys.length; ++j) {
            for (var k = j; k < tableauPileKeys.length; ++k) {
              final cardKey = stockPileCardKeys.removeLast();
              tableauPilesCardKeys[k].add(cardKey);

              final card = findByKey<Card>(cardKey);
              card?.model.parentKey = tableauPileKeys[k];

              await card?.moveToComponent(
                tableauPileKeys[k],
                offset: Vector2(0, Card.stackGap.y * j),
                priority: i,
              );

              ++i;
            }
          }

          maxStockPileCardCount = stockPileCardKeys.length;

          // Flip bottom-most card from each tableau pile
          for (final tableauPileCardKeys in tableauPilesCardKeys) {
            await findByKey<Card>(tableauPileCardKeys.last)?.flip();
          }

          // User can start playing the game
          findByKey<Card>(stockPileCardKeys.last)?.model.isClickable = true;

          for (final tableauPileCardKeys in tableauPilesCardKeys) {
            findByKey<Card>(tableauPileCardKeys.last)?.model.isDraggable = true;
          }
        },
      ),
    ]);
  }
}
