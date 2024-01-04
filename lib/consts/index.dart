import 'package:flame/components.dart';
import 'package:flutter/material.dart';

final worldSize = Vector2(360, 422);
final beginCardGap = Vector2(4, 10);
final cardGap = Vector2(5, 10);
final cardSize = Vector2(46, 70);
final suitSize = Vector2.all(40);
final cardPlaceholderPositionOffset = Vector2(0.75, 1);
final cardPlaceholderSizeOffset = -Vector2(1.5, 2);
const cardBorderRadius = 4.0;
const cardStackGutter = 14;

final cardPlaceholderPaint = Paint()
  ..color = const Color(0xFF804080)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2;

final cardPlaceholderIconPaint = Paint()
  ..colorFilter = const ColorFilter.mode(
    Color(0xFF804080),
    BlendMode.srcIn,
  )
  ..filterQuality = FilterQuality.low;

final cardPlaceholderTextPaint = TextPaint(
  style: const TextStyle(fontSize: 48, color: Color(0xFF804080)),
);

const initialTableauRowCount = 7;
const initialTableauColCount = 7;

const initialTableauCardCount =
    ((initialTableauRowCount + 1) * initialTableauColCount) >> 1;
