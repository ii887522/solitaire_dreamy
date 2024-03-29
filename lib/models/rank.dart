class Rank {
  // Constants
  static const min = 1;
  static const max = 13;

  final int value;

  const Rank(this.value);

  @override
  String toString() {
    return switch (value) {
      1 => 'A',
      11 => 'J',
      12 => 'Q',
      13 => 'K',
      _ => '$value',
    };
  }
}
