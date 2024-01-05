import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:solitaire_dreamy/components/common/shadow_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class StockPile extends PositionComponent with HasGameRef, TapCallbacks {
  final _shadowKey = ComponentKey.unique();

  StockPile({super.key})
      : super(
          position: beginCardGap,
          size: cardSize + cardPlaceholderSizeOffset,
        );

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(
        position: cardPlaceholderPositionOffset,
        size: cardSize + cardPlaceholderSizeOffset,
        paint: cardPlaceholderPaint,
      ),
      SvgComponent(
        svg: await Svg.load('icons/redo.svg', pixelRatio: 4),
        anchor: Anchor.center,
        position: cardSize * 0.5,
        size: Vector2.all(32),
        paint: cardPlaceholderIconPaint,
      ),
      ShadowComponent(
        key: _shadowKey,
        size: cardSize,
        borderRadius: cardBorderRadius,
      ),
    ]);
  }

  void removeShadow() {
    game.findByKey<ShadowComponent>(_shadowKey)?.removeFromParent();
  }

  @override
  void onTapUp(TapUpEvent event) {
    // TODO: Restock from waste piles (like reset)
  }
}
