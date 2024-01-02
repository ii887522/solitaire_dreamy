import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

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

    world?.scale = Vector2.all(
      camera.viewport.size.x / camera.viewport.size.y <
              _worldSize.x / _worldSize.y
          ? camera.viewport.size.x / _worldSize.x
          : camera.viewport.size.y / _worldSize.y,
    );

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
    final beginCardGap = Vector2(4, 10);
    final cardGap = Vector2(5, 10);
    final cardSize = Vector2(46, 70);
    final suitSize = Vector2.all(40);

    final cardPlaceholderPaint = Paint()
      ..color = const Color(0xFF804080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cardPlaceholderIconPaint = Paint()
      ..colorFilter = const ColorFilter.mode(
        Color(0xFF804080),
        BlendMode.srcIn,
      );

    final cardPlaceholderTextPaint = TextPaint(
      style: const TextStyle(fontSize: 48, color: Color(0xFF804080)),
    );

    world.add(
      PositionComponent(
        key: _worldKey,
        children: [
          // StockPile
          RectangleComponent(
            position: beginCardGap,
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/redo.svg'),
            anchor: Anchor.center,
            position: beginCardGap + cardSize * 0.5,
            size: Vector2.all(32),
            paint: cardPlaceholderIconPaint,
          ),

          // WastePile
          RectangleComponent(
            position: beginCardGap + Vector2(cardSize.x + cardGap.x, 0),
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),

          // FoundationPileSpade
          RectangleComponent(
            position: beginCardGap + Vector2(cardSize.x * 3 + cardGap.x * 3, 0),
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/spade.svg'),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 3 + cardGap.x * 3, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileHeart
          RectangleComponent(
            position: beginCardGap + Vector2(cardSize.x * 4 + cardGap.x * 4, 0),
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/heart.svg'),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 4 + cardGap.x * 4, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileClub
          RectangleComponent(
            position: beginCardGap + Vector2(cardSize.x * 5 + cardGap.x * 5, 0),
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/club.svg'),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 5 + cardGap.x * 5, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // FoundationPileDiamond
          RectangleComponent(
            position: beginCardGap + Vector2(cardSize.x * 6 + cardGap.x * 6, 0),
            size: cardSize,
            paint: cardPlaceholderPaint,
          ),
          SvgComponent(
            svg: await Svg.load('icons/diamond.svg'),
            anchor: Anchor.center,
            position: beginCardGap +
                Vector2(cardSize.x * 6 + cardGap.x * 6, 0) +
                cardSize * 0.5,
            size: suitSize,
            paint: cardPlaceholderIconPaint,
          ),

          // TableauPile1
          RectangleComponent(
            position: beginCardGap + Vector2(0, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x + cardGap.x, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x * 2 + cardGap.x * 2, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x * 3 + cardGap.x * 3, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x * 4 + cardGap.x * 4, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x * 5 + cardGap.x * 5, cardSize.y + cardGap.y),
            size: cardSize,
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
                Vector2(cardSize.x * 6 + cardGap.x * 6, cardSize.y + cardGap.y),
            size: cardSize,
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
