import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class PokerCard extends PositionComponent with HasGameRef {
  final ComponentKey? shadowKey;
  final bool hasShadow;
  final _clipKey = ComponentKey.unique();
  final _spriteKey = ComponentKey.unique();

  PokerCard({super.key, this.shadowKey, this.hasShadow = false, super.children})
      : super(position: beginCardGap + cardSize * 0.5, anchor: Anchor.center);

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
          onMax: () {
            // Flip the card horizontally from back to front
            game.findByKey<SpriteComponent>(_spriteKey)?.removeFromParent();

            game.findByKey<ClipComponent>(_clipKey)?.addAll([
              RectangleComponent(
                paint: Paint()..color = Colors.white,
                size: cardSize,
              ),
            ]);
          },
        ),
      ),
    );
  }
}
