import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import '../models/stock_pile_model.dart';
import 'card.dart';

class StockPile extends PositionComponent with TapCallbacks {
  final StockPileModel model;
  final void Function() _onTapUp;

  StockPile({required this.model, void Function()? onTapUp})
      : _onTapUp = onTapUp ?? (() {}),
        super(key: model.key, position: Card.gap, size: Card.size_);

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
    if (model.isClickable) _onTapUp();
  }
}
