import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/shadow_component.dart';

final _worldSize = Vector2(360, 422);

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
    // _worldSize
    world?.scale = Vector2.all(
      camera.viewport.size.x / camera.viewport.size.y <
              _worldSize.x / _worldSize.y
          ? camera.viewport.size.x / _worldSize.x
          : camera.viewport.size.y / _worldSize.y,
    );

    // Position the game world at the top center
    world?.position = Vector2(
      (max(camera.viewport.size.x, _worldSize.x * world.scale.x) -
              _worldSize.x * world.scale.x) *
          0.5,
      0,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // Configuration
    final beginCardGap = Vector2(4, 10);
    final cardGap = Vector2(5, 10);
    final cardSize = Vector2(46, 70);
    final suitSize = Vector2.all(40);
    final cardPlaceholderPositionOffset = Vector2(0.75, 1);
    final cardPlaceholderSizeOffset = -Vector2(1.5, 2);
    const cardBorderRadius = 4.0;

    final cardPlaceholderPaint = Paint()
      ..color = const Color(0xFF804080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cardPlaceholderIconPaint = Paint()
      ..colorFilter = const ColorFilter.mode(
        Color(0xFF804080),
        BlendMode.srcIn,
      )
      ..filterQuality = FilterQuality.low;

    final cardPlaceholderTextPaint = TextPaint(
      style: const TextStyle(fontSize: 48, color: Color(0xFF804080)),
    );

    // Component keys
    final tableauCardKeys = List.generate(29, (index) => ComponentKey.unique());

    world.add(
      PositionComponent(
        key: _worldKey,
        children: [
          // StockPile
          RectangleComponent(
            position: beginCardGap + cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/redo.svg', pixelRatio: 4),
            anchor: Anchor.center,
            position: beginCardGap + cardSize * 0.5,
            size: Vector2.all(32),
            paint: cardPlaceholderIconPaint,
          ),
          ShadowComponent(
            position: beginCardGap,
            size: cardSize,
            borderRadius: cardBorderRadius,
          ),

          // WastePile
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x + cardGap.x, 0) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),

          // FoundationPileSpade
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x * 3 + cardGap.x * 3, 0) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/spade.svg', pixelRatio: 4),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 3 + cardGap.x * 3, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileHeart
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x * 4 + cardGap.x * 4, 0) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/heart.svg', pixelRatio: 4),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 4 + cardGap.x * 4, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileClub
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x * 5 + cardGap.x * 5, 0) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/club.svg', pixelRatio: 4),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 5 + cardGap.x * 5, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileDiamond
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x * 6 + cardGap.x * 6, 0) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/diamond.svg', pixelRatio: 4),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 6 + cardGap.x * 6, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // TableauPile1
          RectangleComponent(
            position: beginCardGap +
                Vector2(0, cardSize.y + cardGap.y) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(0, cardSize.y + cardGap.y) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile2
          RectangleComponent(
            position: beginCardGap +
                Vector2(cardSize.x + cardGap.x, cardSize.y + cardGap.y) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x + cardGap.x, cardSize.y + cardGap.y) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile3
          RectangleComponent(
            position: beginCardGap +
                Vector2(
                  cardSize.x * 2 + cardGap.x * 2,
                  cardSize.y + cardGap.y,
                ) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(
                  cardSize.x * 2 + cardGap.x * 2,
                  cardSize.y + cardGap.y,
                ) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile4
          RectangleComponent(
            position: beginCardGap +
                Vector2(
                  cardSize.x * 3 + cardGap.x * 3,
                  cardSize.y + cardGap.y,
                ) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(
                  cardSize.x * 3 + cardGap.x * 3,
                  cardSize.y + cardGap.y,
                ) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile5
          RectangleComponent(
            position: beginCardGap +
                Vector2(
                  cardSize.x * 4 + cardGap.x * 4,
                  cardSize.y + cardGap.y,
                ) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(
                  cardSize.x * 4 + cardGap.x * 4,
                  cardSize.y + cardGap.y,
                ) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile6
          RectangleComponent(
            position: beginCardGap +
                Vector2(
                  cardSize.x * 5 + cardGap.x * 5,
                  cardSize.y + cardGap.y,
                ) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(
                  cardSize.x * 5 + cardGap.x * 5,
                  cardSize.y + cardGap.y,
                ) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // TableauPile7
          RectangleComponent(
            position: beginCardGap +
                Vector2(
                  cardSize.x * 6 + cardGap.x * 6,
                  cardSize.y + cardGap.y,
                ) +
                cardPlaceholderPositionOffset,
            size: cardSize + cardPlaceholderSizeOffset,
            paint: cardPlaceholderPaint,
          ),
          TextComponent(
            text: 'K',
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(
                  cardSize.x * 6 + cardGap.x * 6,
                  cardSize.y + cardGap.y,
                ) +
                cardSize * 0.5,
            textRenderer: cardPlaceholderTextPaint,
          ),

          // Lays out 28 cards into the tableau piles
          for (var i = 0; i < 7; ++i)
            for (var j = i; j < 7; ++j)
              ShadowComponent(
                key: tableauCardKeys[28 - ((7 - i) * (8 - i) >> 1) + j - i],
                position: beginCardGap,
                size: cardSize,
                borderRadius: cardBorderRadius,
                isEnabled: j == 0,
                children: [
                  ClipComponent(
                    size: cardSize,
                    builder: (size) {
                      return RoundedRectangle.fromPoints(
                        Vector2.zero(),
                        size,
                        cardBorderRadius,
                      );
                    },
                    children: [
                      SpriteComponent(
                        sprite: await Sprite.load('card_back.jpg'),
                        size: cardSize,
                        paint: Paint()..filterQuality = FilterQuality.low,
                      ),
                    ],
                  ),
                  MoveEffect.to(
                    beginCardGap +
                        Vector2(
                          j * (cardSize.x + cardGap.x),
                          cardSize.y + cardGap.y + i * 14,
                        ),
                    EffectController(
                      duration: 0.05,
                      startDelay: (28 - ((7 - i) * (8 - i) >> 1) + j - i) * 0.1,
                    ),
                    onComplete: () {
                      findByKey<ShadowComponent>(
                        tableauCardKeys[
                            28 - ((7 - i) * (8 - i) >> 1) + j - i + 1],
                      )?.isEnabled = true;
                    },
                  ),
                ],
              ),

          // Remaining 24 cards stay in the stock pile
          for (var i = 0; i < 24; ++i)
            ClipComponent(
              position: beginCardGap,
              size: cardSize,
              builder: (size) {
                return RoundedRectangle.fromPoints(
                  Vector2.zero(),
                  size,
                  cardBorderRadius,
                );
              },
              children: [
                SpriteComponent(
                  sprite: await Sprite.load('card_back.jpg'),
                  size: cardSize,
                  paint: Paint()..filterQuality = FilterQuality.low,
                ),
              ],
            ),
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
