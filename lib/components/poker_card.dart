import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/material.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';
import 'package:solitaire_dreamy/models/poker_card_model.dart';
import 'package:solitaire_dreamy/models/rank.dart';

class PokerCard extends PositionComponent with HasGameRef, TapCallbacks {
  final ComponentKey? shadowKey;
  final bool hasShadow;
  final PokerCardModel model;
  final Vector2? manuallyRevealMoveByOffset;
  final _clipKey = ComponentKey.unique();
  final int manuallyRevealedPriority;
  final int resetPriority;
  bool _canManuallyReveal;
  final void Function()? onManuallyReveal;
  var _isFaceUp = false;

  PokerCard({
    super.key,
    this.shadowKey,
    this.hasShadow = false,
    required this.model,
    this.manuallyRevealMoveByOffset,
    canManuallyReveal = false,
    this.manuallyRevealedPriority = 0,
    this.resetPriority = 0,
    this.onManuallyReveal,
    super.children,
  })  : _canManuallyReveal = canManuallyReveal,
        super(
          position: beginCardGap + cardSize * 0.5,
          size: cardSize,
          anchor: Anchor.center,
        );

  set hasShadow(bool value) {
    final shadowKey = this.shadowKey;

    if (shadowKey != null) {
      game.findByKey<ShadowComponent>(shadowKey)?.isEnabled = value;
    }
  }

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

  void flip({double delay = 0.0, void Function()? onComplete}) {
    _isFaceUp = !_isFaceUp;

    add(
      ScaleEffect.by(
        Vector2(0.01, 1),
        EffectController(
          startDelay: delay,
          curve: Curves.easeOutSine,
          duration: 0.05,
          reverseDuration: 0.05,
          onMax: () async {
            final clip = game.findByKey<ClipComponent>(_clipKey);

            // Configuration
            final smallSuitSize = Vector2.all(10);
            final bigSuitSize = Vector2.all(40);
            final suitSvg = await model.suit.toSvg();

            // Flip the card horizontally from back to front
            clip?.removeWhere((component) => true);

            clip?.addAll(
              _isFaceUp
                  ? [
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
                    ]
                  : [
                      SpriteComponent(
                        sprite: await Sprite.load('card_back.jpg'),
                        size: cardSize,
                        paint: Paint()..filterQuality = FilterQuality.low,
                      ),
                    ],
            );
          },
        ),
        onComplete: onComplete,
      ),
    );
  }

  void canManuallyReveal() {
    _canManuallyReveal = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_canManuallyReveal) return;
    onManuallyReveal?.call();
    priority = manuallyRevealedPriority;
    hasShadow = true;
    flip();

    add(
      MoveEffect.by(
        manuallyRevealMoveByOffset ?? Vector2.zero(),
        EffectController(duration: 0.1),
      ),
    );

    _canManuallyReveal = false;
  }

  void moveLeft() {
    add(
      MoveEffect.by(
        Vector2(-cardStackGutter, 0),
        EffectController(duration: 0.1),
      ),
    );
  }

  void reset({void Function()? onComplete}) {
    // Put them back to their original position
    add(
      MoveEffect.to(
        beginCardGap + cardSize * 0.5,
        EffectController(duration: 0.1),
        onComplete: onComplete,
      ),
    );

    // Conceal the card
    canManuallyReveal();
    priority = resetPriority;
    hasShadow = false;
    flip();
  }
}
