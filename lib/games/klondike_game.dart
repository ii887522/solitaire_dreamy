import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Card;
import '../components/card.dart';
import '../components/foundation.dart';
import '../components/foundation_pile.dart';
import '../components/stock_pile.dart';
import '../components/tableau.dart';
import '../components/tableau_pile.dart';
import '../components/waste_pile.dart';
import '../consts/index.dart';
import '../models/card_model.dart';
import '../models/rank.dart';
import '../models/suit.dart';

class KlondikeGame extends FlameGame {
  final playingAreaKey = ComponentKey.unique();

  final _playingAreaSize = Vector2(
    Card.size_.x * 7 + Card.gap.x * 8,
    Card.size_.y * 2 + Card.gap.y * 3 + Card.stackGap.y * 18,
  );

  final _stockPileKey = ComponentKey.unique();

  var _stockPileCardKeys = [
    for (var i = 0; i < Suit.values.length * (Rank.max - Rank.min + 1); ++i)
      ComponentKey.unique()
  ];

  final _wastePileKey = ComponentKey.unique();
  var _wastePileCardKeys = <ComponentKey>[];

  final _tableauPileKeys = [
    for (var i = 0; i < tableauPileCount; ++i) ComponentKey.unique()
  ];

  final _tableauPilesCardKeys = [
    for (var i = 0; i < tableauPileCount; ++i) <ComponentKey>[]
  ];

  final _foundationPileKeys = [
    for (var i = 0; i < foundationPileCount; ++i) ComponentKey.unique()
  ];

  final _foundationPilesCardKeys = [
    for (var i = 0; i < foundationPileCount; ++i) <ComponentKey>[]
  ];

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

    // Prepare a standard 52-card deck
    final cardModels = [
      for (final suit in Suit.values)
        for (var rank = Rank.min; rank <= Rank.max; ++rank)
          CardModel(suit: suit, rank: Rank(rank), parentKey: _stockPileKey)
    ];

    cardModels.shuffle();
    late final int maxStockPileCardCount;

    world.addAll([
      PositionComponent(
        key: playingAreaKey,
        anchor: Anchor.topCenter,
        position: Vector2(camera.viewport.size.x * 0.5, 0),
        size: _playingAreaSize,
        children: [
          StockPile(
            key: _stockPileKey,
            onTapUp: (stockPile) async {
              stockPile.isClickable = false;

              // Restock the stock pile from the waste pile
              _wastePileCardKeys.reverse();
              _stockPileCardKeys = _wastePileCardKeys;
              _wastePileCardKeys = [];
              final effectFutures = <Future<void>>[];

              for (final (i, cardKey) in _stockPileCardKeys.indexed) {
                final card = findByKey<Card>(cardKey);
                card?.model.parentKey = _stockPileKey;
                card?.model.isClickable = false;

                effectFutures.addAll([
                  card?.flip(),
                  card?.moveToComponent(
                    _stockPileKey,
                    hasShadow: i == 0,
                    priority: i,
                  ),
                ].nonNulls);
              }

              await Future.wait(effectFutures);

              if (_stockPileCardKeys.lastOrNull != null) {
                findByKey<Card>(_stockPileCardKeys.last)?.model.isClickable =
                    true;
              }
            },
          ),
          WastePile(key: _wastePileKey),
          Foundation(pileKeys: _foundationPileKeys),
          Tableau(pileKeys: _tableauPileKeys),
          for (final (i, cardKey) in _stockPileCardKeys.indexed)
            Card(
              key: cardKey,
              model: cardModels.removeLast(),
              hasShadow: i == 0,
              onTapUp: (card) async {
                if (card.model.parentKey != _stockPileKey) return;

                // This waste pile card is not draggable due to partially
                // covered by a new card in the waste pile later
                if (_wastePileCardKeys.lastOrNull != null) {
                  findByKey<Card>(_wastePileCardKeys.last)?.model.isDraggable =
                      false;
                }

                // Top-most card from the stock pile reveals to the waste pile
                _wastePileCardKeys.add(_stockPileCardKeys.removeLast());
                card.model.parentKey = _wastePileKey;

                await Future.wait([
                  card.flip(),
                  if (_wastePileCardKeys.length > 3)
                    for (var i = 0; i < 2; ++i)
                      findByKey<Card>(
                        _wastePileCardKeys[_wastePileCardKeys.length - 3 + i],
                      )?.moveToComponent(
                        _wastePileKey,
                        offset: Vector2(i * Card.stackGap.x, 0),
                        hasShadow: i > 0,
                      ),
                  card.moveToComponent(
                    _wastePileKey,
                    offset: Vector2(
                      Card.stackGap.x * (min(_wastePileCardKeys.length - 1, 2)),
                      0,
                    ),
                    priority: maxStockPileCardCount + _wastePileCardKeys.length,
                    hasShadow: true,
                  ),
                ].nonNulls);

                // User can drag the top-most card in the waste pile
                card.model.isDraggable = true;

                if (_stockPileCardKeys.lastOrNull != null) {
                  findByKey<Card>(_stockPileCardKeys.last)?.model.isClickable =
                      true;
                } else {
                  findByKey<StockPile>(_stockPileKey)?.isClickable = true;
                }
              },
              tryStackCard: (stackedCard) async {
                return await _tryStackPile(cardKey, stackedCard);
              },
              tryStackComponents: (stackedComponents) async {
                final stackedPile = stackedComponents
                        .whereType<TableauPile>()
                        .firstOrNull ??
                    stackedComponents.whereType<FoundationPile>().firstOrNull;

                return stackedPile != null
                    ? await _tryStackPile(cardKey, stackedPile)
                    : false;
              },
              findStackingCardKeys: () {
                final card = findByKey<Card>(cardKey);

                // The card must exist, otherwise probably programming errors.
                if (card == null) return [cardKey];

                final tableauPileKeyIndex = _tableauPileKeys.indexOf(
                  card.model.parentKey,
                );

                // The card is dragged from the waste pile and should not have
                // any stacking cards following this card.
                if (tableauPileKeyIndex < 0) return [cardKey];

                return _tableauPilesCardKeys[tableauPileKeyIndex]
                    .getRange(
                      _tableauPilesCardKeys[tableauPileKeyIndex]
                          .indexOf(cardKey),
                      _tableauPilesCardKeys[tableauPileKeyIndex].length,
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
          for (var j = 0; j < _tableauPileKeys.length; ++j) {
            for (var k = j; k < _tableauPileKeys.length; ++k) {
              final cardKey = _stockPileCardKeys.removeLast();
              _tableauPilesCardKeys[k].add(cardKey);
              final card = findByKey<Card>(cardKey);
              card?.model.parentKey = _tableauPileKeys[k];

              await card?.moveToComponent(
                _tableauPileKeys[k],
                offset: Vector2(0, Card.stackGap.y * j),
                priority: i,
                hasShadow: true,
              );

              ++i;
            }
          }

          maxStockPileCardCount = _stockPileCardKeys.length;

          // Flip bottom-most card from each tableau pile
          for (final tableauPileCardKeys in _tableauPilesCardKeys) {
            await findByKey<Card>(tableauPileCardKeys.last)?.flip();
          }

          // User can start playing the game
          findByKey<Card>(_stockPileCardKeys.last)?.model.isClickable = true;

          for (final tableauPileCardKeys in _tableauPilesCardKeys) {
            findByKey<Card>(tableauPileCardKeys.last)?.model.isDraggable = true;
          }
        },
      ),
    ]);
  }

  Future<bool> _tryStackPile(
    ComponentKey stackingCardKey,
    PositionComponent stackedComponent,
  ) async {
    final stackingCard = findByKey<Card>(stackingCardKey);

    // The card must exist, otherwise probably programming errors.
    if (stackingCard == null) return false;

    final int dstPileKeyIndex;
    final List<List<ComponentKey>> pilesCardKeys;

    switch (stackedComponent) {
      case Card(): // Actually stack on top of the card ?
        final stackedCard = stackedComponent;
        final List<ComponentKey> pileKeys;

        final bool Function(
          CardModel stackingCardModel,
          CardModel stackedCardModel,
        ) isStackable;

        // The stacked card belongs to the tableau pile ?
        if (_tableauPileKeys.contains(stackedCard.model.parentKey)) {
          pileKeys = _tableauPileKeys;
          pilesCardKeys = _tableauPilesCardKeys;
          isStackable = TableauPile.isStackable;

          // The stacked card belongs to the foundation pile ?
        } else if (_foundationPileKeys.contains(stackedCard.model.parentKey)) {
          pileKeys = _foundationPileKeys;
          pilesCardKeys = _foundationPilesCardKeys;
          isStackable = FoundationPile.isStackable;

          // Maybe we try to stack the card on top of the stock pile, waste pile
          // or etc which is not allowed
        } else {
          return false;
        }

        dstPileKeyIndex = pileKeys.indexOf(stackedCard.model.parentKey);

        // Only can stack on top of the bottom-most card in the tableau pile or
        // top-most card in the foundation pile
        if (dstPileKeyIndex < 0 ||
            stackedCard.key != pilesCardKeys[dstPileKeyIndex].last) {
          return false;
        }

        // Is stackable according to the classic Klondike game rules ?
        if (!isStackable(stackingCard.model, stackedCard.model)) return false;

      case TableauPile(): // Actually stack on top of the empty tableau pile ?
        // Is stackable according to the classic Klondike game rules ?
        if (!TableauPile.isStackableBy(stackingCard.model)) return false;

        final stackedTableauPile = stackedComponent;
        dstPileKeyIndex = _tableauPileKeys.indexOf(stackedTableauPile.key);
        pilesCardKeys = _tableauPilesCardKeys;

      // Actually stack on top of the empty foundation pile ?
      case FoundationPile():
        final stackedFoundationPile = stackedComponent;

        // Is stackable according to the classic Klondike game rules ?
        if (!stackedFoundationPile.isStackableBy(stackingCard.model)) {
          return false;
        }

        dstPileKeyIndex =
            _foundationPileKeys.indexOf(stackedFoundationPile.key);

        pilesCardKeys = _foundationPilesCardKeys;

      default:
        // Maybe we try to stack the card on top of the stock pile, waste pile
        // or etc which is not allowed
        return false;
    }

    final effectFutures = <Future<void>>[];
    void Function()? onEffectsDone;

    // The card is coming from the waste pile ?
    if (stackingCard.model.parentKey == _wastePileKey) {
      // Only the top-most waste pile card can be removed. So can assume always
      // remove the last card key
      pilesCardKeys[dstPileKeyIndex].add(_wastePileCardKeys.removeLast());

      if (_wastePileCardKeys.lastOrNull != null) {
        onEffectsDone = () {
          findByKey<Card>(_wastePileCardKeys.last)?.model.isDraggable = true;
        };
      }

      // The card is coming from the tableau pile ?
    } else if (_tableauPileKeys.contains(stackingCard.model.parentKey)) {
      final srcPileKeyIndex =
          _tableauPileKeys.indexOf(stackingCard.model.parentKey);

      final srcTableauPileCardKeys = _tableauPilesCardKeys[srcPileKeyIndex];

      final srcTableauPileCardKeyIndex =
          srcTableauPileCardKeys.indexOf(stackingCardKey);

      // Actually stack on top of the tableau pile
      if (pilesCardKeys == _tableauPilesCardKeys) {
        // Move the bottom section of cards between tableau piles
        if (srcPileKeyIndex != dstPileKeyIndex) {
          _tableauPilesCardKeys[dstPileKeyIndex].addAll(
            srcTableauPileCardKeys.getRange(
              srcTableauPileCardKeyIndex,
              srcTableauPileCardKeys.length,
            ),
          );

          srcTableauPileCardKeys.removeRange(
            srcTableauPileCardKeyIndex,
            srcTableauPileCardKeys.length,
          );
        }

        // Actually stack on top of the foundation pile
      } else {
        if (srcTableauPileCardKeyIndex < srcTableauPileCardKeys.length - 1) {
          // Cannot stack multiple cards on top of the foundation pile
          // according to the classic Klondike game rules
          return false;
        }

        // Only the bottom-most tableau pile card can be removed. So can assume
        // always remove the last card key.
        _foundationPilesCardKeys[dstPileKeyIndex].add(
          srcTableauPileCardKeys.removeLast(),
        );
      }

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

      // The card is coming from the foundation pile
      // Actually stack on top of the tableau pile
    } else if (pilesCardKeys == _tableauPilesCardKeys) {
      // Move the card back to the tableau pile.
      final srcFoundationPileCardKeys = _foundationPilesCardKeys[
          _foundationPileKeys.indexOf(stackingCard.model.parentKey)];

      // Only the top-most foundation pile card can be removed. So can assume
      // always remove the last card key.
      _tableauPilesCardKeys[dstPileKeyIndex].add(
        srcFoundationPileCardKeys.removeLast(),
      );

      if (srcFoundationPileCardKeys.lastOrNull != null) {
        findByKey<Card>(srcFoundationPileCardKeys.last)?.model.isDraggable =
            true;
      }

      // The card is coming from the foundation pile
      // Actually stack on top of the foundation pile
    } else {
      // The stacking card is already in the foundation pile and no actions
      // should be done according to the classic Klondike game rules, so
      // considered failed to stack to return back to the previous position
      return false;
    }

    effectFutures.addAll([
      if (stackingCard.model.parentKey == _wastePileKey &&
          _wastePileCardKeys.length >= 3)
        for (var i = 0; i < 2; ++i)
          findByKey<Card>(
            _wastePileCardKeys[_wastePileCardKeys.length - 2 + i],
          )?.moveToComponent(
            _wastePileKey,
            offset: Vector2(Card.stackGap.x * (i + 1), 0),
            hasShadow: true,
          ),
    ].nonNulls);

    // Actually stack on top of the tableau pile
    if (pilesCardKeys == _tableauPilesCardKeys) {
      final dstTableauPileCardKeyIndex =
          _tableauPilesCardKeys[dstPileKeyIndex].indexOf(stackingCardKey);

      final stackingCardKeys = _tableauPilesCardKeys[dstPileKeyIndex].getRange(
        dstTableauPileCardKeyIndex,
        _tableauPilesCardKeys[dstPileKeyIndex].length,
      );

      effectFutures.addAll([
        for (final (i, stackingCardKey) in stackingCardKeys.indexed)
          findByKey<Card>(stackingCardKey)?.moveToComponent(
            _tableauPileKeys[dstPileKeyIndex],
            offset: Vector2(
              0,
              Card.stackGap.y * (dstTableauPileCardKeyIndex + i),
            ),
            priority: stackedComponent.priority + 1 + i,
            hasShadow: true,
          ),
      ].nonNulls);

      for (final stackingCardKey in stackingCardKeys) {
        findByKey<Card>(stackingCardKey)?.model.parentKey =
            _tableauPileKeys[dstPileKeyIndex];
      }

      // Actually stack on top of the foundation pile
    } else {
      if (stackedComponent is Card) stackedComponent.model.isDraggable = false;

      effectFutures.add(
        stackingCard.moveToComponent(
          _foundationPileKeys[dstPileKeyIndex],
          hasShadow: _foundationPilesCardKeys[dstPileKeyIndex].length == 1,
          priority: stackedComponent.priority + 1,
        ),
      );

      stackingCard.model.parentKey = _foundationPileKeys[dstPileKeyIndex];
    }

    await Future.wait(effectFutures);
    onEffectsDone?.call();
    return true;
  }
}
