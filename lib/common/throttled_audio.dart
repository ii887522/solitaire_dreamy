import 'package:flame_audio/flame_audio.dart';

class ThrottledAudio {
  final String file;
  final int limit;
  var _playingCount = 0;

  ThrottledAudio(this.file, {this.limit = 1});

  Future<void> play({double volume = 1.0}) async {
    if (_playingCount == limit) return;
    ++_playingCount;
    final player = await FlameAudio.play(file, volume: volume);

    // player.onPlayerComplete callback seems not called at all in Android or
    // possibly other platforms. Simulate onPlayerComplete callback by delaying
    // completion code for this audio duration after played.
    Future.delayed(
      await player.getDuration() ?? Duration.zero,
      () => --_playingCount,
    );
  }
}
