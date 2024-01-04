import 'package:flame_svg/svg.dart';
import 'package:flutter/material.dart';

enum Suit {
  spade,
  heart,
  club,
  diamond;

  Color toColor() {
    return this == spade || this == club
        ? Colors.black
        : const Color(0xFFDD1A1E);
  }

  Future<Svg> toSvg() async {
    return await Svg.load(
      switch (this) {
        Suit.spade => 'icons/spade.svg',
        Suit.heart => 'icons/heart.svg',
        Suit.club => 'icons/club.svg',
        Suit.diamond => 'icons/diamond.svg',
      },
      pixelRatio: 4,
    );
  }

  Paint toPaint({double opacity = 1}) {
    return Paint()
      ..colorFilter = ColorFilter.mode(
        switch (this) {
          Suit.spade || Suit.club => Colors.black,
          Suit.heart || Suit.diamond => const Color(0xFFDD1A1E),
        }
            .withOpacity(opacity),
        BlendMode.srcIn,
      )
      ..filterQuality = FilterQuality.low;
  }
}
