import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

enum Suit {
  spade,
  heart,
  club,
  diamond;

  Color toColor() {
    return switch (this) {
      spade || club => Colors.black,
      heart || diamond => const Color(0xFFDD1A1E),
    };
  }

  Future<Svg> toSvg() async {
    return await Svg.load(
      switch (this) {
        spade => 'icons/spade.svg',
        heart => 'icons/heart.svg',
        club => 'icons/club.svg',
        diamond => 'icons/diamond.svg',
      },
      pixelRatio: 4,
    );
  }

  Paint toSmallPaint() => Paint()
    ..colorFilter = ColorFilter.mode(toColor(), BlendMode.srcIn)
    ..filterQuality = FilterQuality.low;

  Paint toBigPaint() => Paint()
    ..colorFilter =
        ColorFilter.mode(toColor().withOpacity(0.25), BlendMode.srcIn)
    ..filterQuality = FilterQuality.low;
}
