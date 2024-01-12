import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import 'card.dart';

class StockPile extends PositionComponent with TapCallbacks {
  var isClickable = false;
  final void Function(StockPile stockPile) _onTapUp;

  StockPile({super.key, void Function(StockPile stockPile)? onTapUp})
      : _onTapUp = onTapUp ?? ((stockPile) {}),
        super(position: Card.gap, size: Card.size_);

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
      SvgComponent(
        svg: await Svg.load('icons/redo.svg', pixelRatio: 4),
        anchor: Anchor.center,
        position: size * 0.5,
        size: Vector2.all(32),
        paint: cardPlaceholderSvgPaint,
      ),
    ]);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isClickable) _onTapUp(this);
  }
}
