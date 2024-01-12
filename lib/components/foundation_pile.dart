import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import '../consts/index.dart';
import 'card.dart';

class FoundationPile extends PositionComponent {
  final String iconFileName;

  FoundationPile({super.position, required this.iconFileName})
      : super(size: Card.size_);

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(size: Card.size_, paint: cardPlaceholderBorderPaint),
      SvgComponent(
        svg: await Svg.load(iconFileName, pixelRatio: 4),
        anchor: Anchor.center,
        position: size * 0.5,
        size: Vector2.all(40),
        paint: cardPlaceholderSvgPaint,
      ),
    ]);
  }
}
