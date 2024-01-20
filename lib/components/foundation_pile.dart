import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import '../models/foundation_pile_model.dart';
import 'card.dart';

class FoundationPile extends PositionComponent {
  final FoundationPileModel model;

  FoundationPile({super.position, required this.model})
      : super(key: model.key, size: Card.size_);

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
      SvgComponent(
        svg: await model.suit.toSvg(),
        anchor: Anchor.center,
        position: size * 0.5,
        size: Vector2.all(40),
        paint: cardPlaceholderSvgPaint,
      ),
    ]);
  }
}
