import 'package:flutter/material.dart';

// Card placeholder
const cardPlaceholderColor = Color(0xFF804080);

final cardPlaceholderBorderPaint = Paint()
  ..color = cardPlaceholderColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.0;

final cardPlaceholderSvgPaint = Paint()
  ..colorFilter = const ColorFilter.mode(cardPlaceholderColor, BlendMode.srcIn)
  ..filterQuality = FilterQuality.low;

// Others
const tableauPileCount = 7;
