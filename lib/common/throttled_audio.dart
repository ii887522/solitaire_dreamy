import 'package:flame_audio/flame_audio.dart';

class ThrottledAudio {
  final String file;
  final int limit;
  var _playingCount = 0;

  ThrottledAudio(this.file, {this.limit = 1});

  Future<void> play({double volume = 1.0}) async {
    if (_playingCount == limit) return;
    ++_playingCount;

    (await FlameAudio.play(file, volume: volume))
        .onPlayerComplete
        .first
        .then((_) => --_playingCount);
  }
}
