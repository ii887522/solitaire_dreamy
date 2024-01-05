import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:solitaire_dreamy/consts/index.dart';

class FoundationPile extends PositionComponent {
  final String suitIconFileName;

  FoundationPile({super.position, required this.suitIconFileName})
      : super(size: cardSize + cardPlaceholderSizeOffset);

  @override
  FutureOr<void> onLoad() async {
    addAll([
      RectangleComponent(
        position: cardPlaceholderPositionOffset,
        size: cardSize + cardPlaceholderSizeOffset,
        paint: cardPlaceholderPaint,
      ),
      SvgComponent(
        svg: await Svg.load(suitIconFileName, pixelRatio: 4),
        anchor: Anchor.center,
        position: cardSize * 0.5,
        size: suitSize,
        paint: cardPlaceholderIconPaint,
      ),
    ]);
  }
}
