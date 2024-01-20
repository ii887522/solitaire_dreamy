import 'package:flame/components.dart';
import 'klondike.dart';
import 'rank.dart';
import 'suit.dart';

class CardModel {
  final Klondike game;
  final Suit suit;
  final Rank rank;
  var _prevIsFaceUp = false;
  var _isFaceUp = false;
  var stackingCards = <CardModel>[];

  // Component keys
  final key = ComponentKey.unique();
  ComponentKey _prevParentKey;
  ComponentKey _parentKey;

  // User events
  var isClickable = false;
  var isDraggable = false;

  CardModel({
    required this.suit,
    required this.rank,
    required ComponentKey parentKey,
    required this.game,
  })  : _prevParentKey = parentKey,
        _parentKey = parentKey;

  bool get prevIsFaceUp => _prevIsFaceUp;
  bool get isFaceUp => _isFaceUp;
  ComponentKey get parentKey => _parentKey;
  ComponentKey get prevParentKey => _prevParentKey;

  set parentKey(ComponentKey parentKey) {
    _prevParentKey = _parentKey;
    _parentKey = parentKey;
  }

  set isFaceUp(bool isFaceUp) {
    _prevIsFaceUp = _isFaceUp;
    _isFaceUp = isFaceUp;
  }

  void allowDrag() {
    for (final stackingCard in stackingCards) {
      stackingCard.isDraggable = true;
    }

    game.isDraggingCard = false;
  }
}
