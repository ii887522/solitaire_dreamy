import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/card_back.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/components/foundation.dart';
import 'package:solitaire_dreamy/components/stock_pile.dart';
import 'package:solitaire_dreamy/components/tableau.dart';
import 'package:solitaire_dreamy/components/waste_pile.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class KlondikeGame extends FlameGame {
  final _worldKey = ComponentKey.unique();
  var _isIniting = true;

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

    // Configuration
    const initialTableauRowCount = 7;
    const initialTableauColCount = 7;
    const cardStackGutter = 14;

    // Component keys
    final tableauCardKeys = List.generate(29, (index) => ComponentKey.unique());

    world.add(
      PositionComponent(
        key: _worldKey,
        children: [
          StockPile(),
          WastePile(),
          Foundation(),
          Tableau(),

          // Lays out 28 cards into the tableau piles
          for (var rowIndex = 0; rowIndex < initialTableauRowCount; ++rowIndex)
            for (var colIndex = rowIndex;
                colIndex < initialTableauColCount;
                ++colIndex)
              () {
                final index =
                    (((initialTableauRowCount + 1) * initialTableauColCount) >>
                            1) -
                        (((initialTableauColCount - rowIndex) *
                                (initialTableauRowCount + 1 - rowIndex)) >>
                            1) +
                        colIndex -
                        rowIndex;

                return CardBack(
                  shadowKey: tableauCardKeys[index],
                  hasShadow: colIndex == 0,
                  children: [
                    MoveEffect.to(
                      beginCardGap +
                          Vector2(
                            colIndex * (cardSize.x + cardGap.x),
                            cardSize.y + cardGap.y + rowIndex * cardStackGutter,
                          ),
                      EffectController(
                        duration: 0.08,
                        startDelay: index * 0.16,
                      ),
                      onComplete: () {
                        final cardShadow = findByKey<ShadowComponent>(
                          tableauCardKeys[index + 1],
                        );

                        if (cardShadow != null) {
                          cardShadow.isEnabled = true;
                        } else {
                          // TODO: Reveal bottom-most card from each tableau pile
                        }
                      },
                    ),
                  ],
                );
              }(),

          // Remaining 24 cards stay in the stock pile
          for (var i = 0; i < 24; ++i) CardBack(),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isIniting) {
      // Fix the world components' position and size according to the current
      // window size
      onGameResize(size);

      _isIniting = false;
    }
  }
}
