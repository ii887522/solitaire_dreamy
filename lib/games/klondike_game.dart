import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/poker_card.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/components/foundation.dart';
import 'package:solitaire_dreamy/components/stock_pile.dart';
import 'package:solitaire_dreamy/components/tableau.dart';
import 'package:solitaire_dreamy/components/waste_pile.dart';
import 'package:solitaire_dreamy/consts/index.dart';
import 'package:solitaire_dreamy/models/poker_card_model.dart';
import 'package:solitaire_dreamy/models/suit.dart';

class KlondikeGame extends FlameGame {
  final _worldKey = ComponentKey.unique();

  final _initialTableauCardKeys = List.generate(
    initialTableauCardCount,
    (index) => ComponentKey.unique(),
  );

  final _tableauCardShadowKeys = List.generate(
    initialTableauCardCount + 1,
    (index) => ComponentKey.unique(),
  );

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Assume that the world components are defined in the boundary
    final world = findByKey<PositionComponent>(_worldKey);

    // Expand the game world to fill as much space as possible inside the window
    // or screen while maintaining the game world aspect ratio calculated from
    // worldSize
    world?.scale = Vector2.all(
      camera.viewport.size.x / camera.viewport.size.y <
              worldSize.x / worldSize.y
          ? camera.viewport.size.x / worldSize.x
          : camera.viewport.size.y / worldSize.y,
    );

    // Position the game world at the top center
    world?.position = Vector2(
      (max(camera.viewport.size.x, worldSize.x * world.scale.x) -
              worldSize.x * world.scale.x) *
          0.5,
      0,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // Shuffle a standard 52-card deck
    final pokerCardModels = [
      for (final suit in Suit.values)
        for (var rank = 1; rank <= 13; ++rank)
          PokerCardModel(suit: suit, rank: rank)
    ];

    pokerCardModels.shuffle();

    world.addAll([
      PositionComponent(
        key: _worldKey,
        children: [
          StockPile(),
          WastePile(),
          Foundation(),
          Tableau(),

          // Prepare to lay out 28 cards from the stock pile into the tableau
          // piles
          for (var rowIndex = 0; rowIndex < initialTableauRowCount; ++rowIndex)
            for (var colIndex = rowIndex;
                colIndex < initialTableauColCount;
                ++colIndex)
              () {
                final index = initialTableauCardCount -
                    (((initialTableauColCount - rowIndex) *
                            (initialTableauRowCount + 1 - rowIndex)) >>
                        1) +
                    colIndex -
                    rowIndex;

                return PokerCard(
                  key: _initialTableauCardKeys[index],
                  shadowKey: _tableauCardShadowKeys[index],
                  hasShadow: colIndex == 0,
                  model: pokerCardModels.removeLast(),
                );
              }(),

          // Remaining 24 cards stay in the stock pile
          ...pokerCardModels.map(
            (pokerCardModel) => PokerCard(model: pokerCardModel),
          ),
        ],
      ),

      // Delay initialization that depends on components to ensure that they are
      // fully mounted and accessible
      TimerComponent(
        period: double.minPositive,
        removeOnFinish: true,
        onTick: () {
          // Fix the world components' position and size according to the
          // current window size
          onGameResize(size);

          // Lay out 28 cards from the stock pile into the tableau piles
          _layOutCard(rowIndex: 0, colIndex: 0);
        },
      ),
    ]);
  }

  void _layOutCard({required int rowIndex, required int colIndex}) {
    final index = initialTableauCardCount -
        (((initialTableauColCount - rowIndex) *
                (initialTableauRowCount + 1 - rowIndex)) >>
            1) +
        colIndex -
        rowIndex;

    final initialTableauCard = findByKey<PokerCard>(
      _initialTableauCardKeys[index],
    );

    initialTableauCard?.priority = rowIndex + 1;

    initialTableauCard?.add(
      MoveEffect.by(
        Vector2(
          colIndex * (cardSize.x + cardGap.x),
          cardSize.y + cardGap.y + rowIndex * cardStackGutter,
        ),
        EffectController(duration: 0.1),
        onComplete: () {
          final cardShadow = findByKey<ShadowComponent>(
            _tableauCardShadowKeys[index + 1],
          );

          // Still have card yet to lay out ?
          if (cardShadow != null) {
            cardShadow.isEnabled = true;

            // Lays out the next card
            if (colIndex != 6) {
              _layOutCard(rowIndex: rowIndex, colIndex: colIndex + 1);
            } else {
              _layOutCard(rowIndex: rowIndex + 1, colIndex: rowIndex + 1);
            }

            return;
          }

          // Reveal bottom-most card from each tableau pile
          for (var rowIndex = 0;
              rowIndex < initialTableauRowCount;
              ++rowIndex) {
            final index = initialTableauCardCount -
                (((initialTableauColCount - rowIndex) *
                        (initialTableauRowCount + 1 - rowIndex)) >>
                    1);

            findByKey<PokerCard>(_initialTableauCardKeys[index])
                ?.reveal(delay: rowIndex * 0.1);
          }
        },
      ),
    );
  }
}
