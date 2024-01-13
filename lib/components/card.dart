import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import '../extensions/platform_ext.dart';
import '../games/klondike_game.dart';
import '../models/card_model.dart';
import 'common/shadow_component.dart';

class Card extends PositionComponent
    with HasGameRef<KlondikeGame>, TapCallbacks, DragCallbacks {
  // Constants
  static Vector2 get gap => Vector2(4, 10);
  static Vector2 get size_ => Vector2(46, 70);
  static Vector2 get stackGap => Vector2.all(14);
  static const cornerRadius = 4.0;

  final ComponentKey key;
  final CardModel model;
  final bool hasShadow;
  var _stackingCardKeys = <ComponentKey>[];

  // Callbacks
  final void Function(Card card) _onTapUp;
  final Future<bool> Function(Card stackedCard) _tryStackCard;

  final Future<bool> Function(Iterable<Component> stackedComponents)
      _tryStackComponents;

  final List<ComponentKey> Function() _findStackingCardKeys;

  // Component keys
  final _shadowKey = ComponentKey.unique();
  final _clipKey = ComponentKey.unique();

  // Ephemeral state to save and restore
  var _prevPriority = 0;
  var _prevOffset = Vector2.zero();
  bool _prevHasShadow;

  Card({
    required this.key,
    required this.model,
    this.hasShadow = false,
    void Function(Card card)? onTapUp,
    Future<bool> Function(Card stackedCard)? tryStackCard,
    Future<bool> Function(Iterable<Component> stackedComponents)?
        tryStackComponents,
    List<ComponentKey> Function()? findStackingCardKeys,
  })  : _onTapUp = onTapUp ?? ((card) {}),
        _tryStackCard = tryStackCard ?? ((stackedCard) => Future.value(false)),
        _tryStackComponents =
            tryStackComponents ?? ((stackedComponents) => Future.value(false)),
        _findStackingCardKeys = findStackingCardKeys ?? (() => []),
        _prevHasShadow = hasShadow,
        super(
          key: key,
          anchor: Anchor.center,
          position: gap + size_ * 0.5,
          size: size_,
        );

  @override
  FutureOr<void> onLoad() async {
    add(
      ShadowComponent(
        key: _shadowKey,
        isEnabled: hasShadow,
        size: size,
        cornerRadius: Card.cornerRadius,
        children: [
          ClipComponent(
            key: _clipKey,
            size: size,
            builder: (size) {
              return RoundedRectangle.fromPoints(
                Vector2.zero(),
                size,
                cornerRadius,
              );
            },
            children: [
              SpriteComponent(
                sprite: await Sprite.load('card_back.jpg'),
                size: size,
                paint: Paint()..filterQuality = FilterQuality.low,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> moveToComponent(
    ComponentKey componentKey, {
    Vector2? offset,
    int? priority,
    bool? hasShadow,
  }) {
    offset = offset ?? Vector2.zero();
    _prevOffset = offset;

    final componentAbsolutePosition =
        game.findByKey<PositionComponent>(componentKey)?.absolutePosition ??
            Vector2.zero();

    final playingArea = game.findByKey<PositionComponent>(game.playingAreaKey);
    final playingAreaPosition = playingArea?.topLeftPosition ?? Vector2.zero();
    final playingAreaScale = playingArea?.scale.x ?? 1;
    final completer = Completer<void>();

    if (hasShadow != null) {
      game.findByKey<ShadowComponent>(_shadowKey)?.isEnabled = hasShadow;
    }

    if (priority != null) this.priority = priority;

    add(
      MoveEffect.to(
        (componentAbsolutePosition - playingAreaPosition) / playingAreaScale +
            size * 0.5 +
            offset,
        EffectController(duration: 0.1, curve: Curves.easeOut),
        onComplete: () => completer.complete(),
      ),
    );

    return completer.future;
  }

  Future<void> flip() {
    model.isFaceUp = !model.isFaceUp;
    final completer = Completer<void>();

    add(
      ScaleEffect.by(
        Vector2(0.01, 1),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          curve: Curves.easeOutSine,
          reverseCurve: Curves.easeInSine,
          onMax: () async {
            final clip = game.findByKey<ClipComponent>(_clipKey);
            clip?.removeWhere((component) => true);

            // Configurations
            final smallSuitSize = Vector2.all(10);
            final bigSuitSize = Vector2.all(40);
            final suitSvg = await model.suit.toSvg();

            clip?.addAll(
              model.isFaceUp
                  ? [
                      RectangleComponent(
                        size: size,
                        paint: Paint()..color = Colors.white,
                      ),
                      TextComponent(
                        text: '${model.rank}',
                        anchor: Anchor.center,
                        position: PlatformExt.isMobile
                            ? Vector2(6, 7)
                            : Vector2.all(6),
                        textRenderer: TextPaint(
                          style: TextStyle(
                            fontSize: 12,
                            color: model.suit.toColor(),
                            fontWeight: FontWeight.w500,
                            letterSpacing: PlatformExt.isMobile ? -2.25 : -1,
                          ),
                        ),
                      ),
                      SvgComponent(
                        svg: suitSvg,
                        anchor: Anchor.center,
                        position: Vector2(size.x - 6, 7),
                        size: smallSuitSize,
                        paint: model.suit.toSmallPaint(),
                      ),
                      SvgComponent(
                        svg: suitSvg,
                        anchor: Anchor.center,
                        position: Vector2(6, 18),
                        size: smallSuitSize,
                        paint: model.suit.toSmallPaint(),
                      ),
                      SvgComponent(
                        svg: suitSvg,
                        anchor: Anchor.center,
                        position: size * 0.5 + Vector2(0, 5),
                        size: bigSuitSize,
                        paint: model.suit.toBigPaint(),
                      ),
                      TextComponent(
                        text: '${model.rank}',
                        anchor: Anchor.center,
                        position: size * 0.5 +
                            (PlatformExt.isMobile
                                ? Vector2(0, 5)
                                : Vector2(0, 2)),
                        textRenderer: TextPaint(
                          style: TextStyle(
                            fontSize: 48,
                            color: model.suit.toColor(),
                            fontWeight: FontWeight.w500,
                            letterSpacing: PlatformExt.isMobile ? -9 : -4,
                          ),
                        ),
                      ),
                    ]
                  : [
                      SpriteComponent(
                        sprite: await Sprite.load('card_back.jpg'),
                        size: size,
                        paint: Paint()..filterQuality = FilterQuality.low,
                      ),
                    ],
            );
          },
        ),
        onComplete: () => completer.complete(),
      ),
    );

    return completer.future;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (model.isClickable) _onTapUp(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!model.isDraggable) return;
    super.onDragStart(event);
    _stackingCardKeys = _findStackingCardKeys();

    for (final (i, stackingCardKey) in _stackingCardKeys.indexed) {
      final stackingCard = game.findByKey<Card>(stackingCardKey);
      if (stackingCard == null) continue;
      stackingCard.model.isDraggable = false;
      stackingCard._prevPriority = stackingCard.priority;
      stackingCard.priority = 100 + i;
      final shadow = game.findByKey<ShadowComponent>(stackingCard._shadowKey);
      stackingCard._prevHasShadow = shadow?.isEnabled ?? false;
      shadow?.isEnabled = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isDragged) return;

    for (final stackingCardKey in _stackingCardKeys) {
      game.findByKey<Card>(stackingCardKey)?.position += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    if (!isDragged) return;
    super.onDragEnd(event);

    final stackedComponents = game
            .findByKey<PositionComponent>(game.playingAreaKey)
            ?.componentsAtPoint(
              position -
                  (_stackingCardKeys.length == 1
                      ? Vector2.zero()
                      : Vector2(0, (size.y - Card.stackGap.y) * 0.5)),
            ) ??
        [];

    final stackedCard = stackedComponents.whereType<Card>().elementAtOrNull(1);

    if (stackedCard != null) {
      if (!await _tryStackCard(stackedCard)) {
        // Failed to stack the card
        await _returnBack();
      }
    } else if (!await _tryStackComponents(stackedComponents)) {
      // Failed to stack the card
      await _returnBack();
    }

    _allowDrag();
  }

  Future<void> _returnBack() async {
    final effectFutures = <Future<void>>[];

    for (final stackingCardKey in _stackingCardKeys) {
      final stackingCard = game.findByKey<Card>(stackingCardKey);

      effectFutures.add(
        stackingCard?.moveToComponent(
              stackingCard.model.parentKey,
              offset: stackingCard._prevOffset,
            ) ??
            Future.value(),
      );
    }

    await Future.wait(effectFutures);

    for (final stackingCardKey in _stackingCardKeys) {
      final stackingCard = game.findByKey<Card>(stackingCardKey);
      if (stackingCard == null) continue;
      stackingCard.priority = stackingCard._prevPriority;

      game.findByKey<ShadowComponent>(stackingCard._shadowKey)?.isEnabled =
          stackingCard._prevHasShadow;
    }
  }

  void _allowDrag() {
    for (final stackingCardKey in _stackingCardKeys) {
      game.findByKey<Card>(stackingCardKey)?.model.isDraggable = true;
    }
  }
}
