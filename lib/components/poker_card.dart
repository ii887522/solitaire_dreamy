import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';
import 'package:solitaire_dreamy/models/poker_card_model.dart';
import 'package:solitaire_dreamy/models/rank.dart';

class PokerCard extends PositionComponent with HasGameRef {
  final ComponentKey? shadowKey;
  final bool hasShadow;
  final PokerCardModel model;
  final _clipKey = ComponentKey.unique();
  final _spriteKey = ComponentKey.unique();

  PokerCard({
    super.key,
    this.shadowKey,
    this.hasShadow = false,
    required this.model,
    super.children,
  }) : super(position: beginCardGap + cardSize * 0.5, anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() async {
    add(
      ShadowComponent(
        key: shadowKey,
        position: -cardSize * 0.5,
        size: cardSize,
        borderRadius: cardBorderRadius,
        isEnabled: hasShadow,
        children: [
          ClipComponent(
            key: _clipKey,
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
                key: _spriteKey,
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

  void reveal({double delay = 0.0}) {
    add(
      ScaleEffect.by(
        Vector2(0.01, 1),
        EffectController(
          startDelay: delay,
          curve: Curves.easeOutSine,
          duration: 0.05,
          reverseDuration: 0.05,
          onMax: () async {
            // Flip the card horizontally from back to front
            game.findByKey<SpriteComponent>(_spriteKey)?.removeFromParent();

            // Configuration
            final smallSuitSize = Vector2.all(10);
            final bigSuitSize = Vector2.all(40);
            final suitSvg = await model.suit.toSvg();

            game.findByKey<ClipComponent>(_clipKey)?.addAll([
              RectangleComponent(
                paint: Paint()..color = Colors.white,
                size: cardSize,
              ),
              TextComponent(
                text: '${Rank(model.rank)}',
                anchor: Anchor.topCenter,
                position: Vector2(6, 0),
                textRenderer: TextPaint(
                  style: TextStyle(
                    fontSize: 12,
                    color: model.suit.toColor(),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                  ),
                ),
              ),
              SvgComponent(
                svg: suitSvg,
                anchor: Anchor.topCenter,
                position: Vector2(cardSize.x - 6, 4),
                size: smallSuitSize,
                paint: model.suit.toPaint(),
              ),
              SvgComponent(
                svg: suitSvg,
                anchor: Anchor.topCenter,
                position: Vector2(5.8, 15),
                size: smallSuitSize,
                paint: model.suit.toPaint(),
              ),
              SvgComponent(
                svg: suitSvg,
                anchor: Anchor.center,
                position: cardSize * 0.5 + Vector2(0, 6),
                size: bigSuitSize,
                paint: model.suit.toPaint(opacity: 0.25),
              ),
              TextComponent(
                text: '${Rank(model.rank)}',
                anchor: Anchor.center,
                position: cardSize * 0.5 + Vector2(0, 2.5),
                textRenderer: TextPaint(
                  style: TextStyle(
                    fontSize: 48,
                    color: model.suit.toColor(),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -4,
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
