import 'package:flame/components.dart';
import 'rank.dart';
import 'suit.dart';

class CardModel {
  final Suit suit;
  final Rank rank;
  var isFaceUp = false;
  ComponentKey parentKey;

  // User events
  var isClickable = false;
  var isDraggable = false;

  CardModel({required this.suit, required this.rank, required this.parentKey});
}
