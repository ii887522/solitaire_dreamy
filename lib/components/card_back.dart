import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class CardBack extends PositionComponent {
  final ComponentKey? shadowKey;
  final bool hasShadow;

  CardBack({this.shadowKey, this.hasShadow = false, super.children})
      : super(position: beginCardGap);

  @override
  FutureOr<void> onLoad() async {
    add(
      ShadowComponent(
        key: shadowKey,
        size: cardSize,
        borderRadius: cardBorderRadius,
        isEnabled: hasShadow,
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
        ],
      ),
    );
  }
}
