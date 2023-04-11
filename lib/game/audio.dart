import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Audio extends Component with HasGameRef {
  late bool music;
  late bool effects;

  @override
  Future<void>? onLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    music = prefs.getBool('music') ?? true;
    effects = prefs.getBool('effects') ?? true;

    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache
        .loadAll(['block_hit.wav', 'power_hit.wav', 'music.mp3']);

    try {
      await FlameAudio.audioCache.load(
        'music.mp3',
      );
    } catch (_) {
      //print(_);
    }

    return super.onLoad();
  }

  void playMusic(String audioName) {
    if (game.buildContext != null) {
      if (music) {
        FlameAudio.bgm.play(audioName);
      }
    }
  }

  void playSfx(String audioName) {
    if (game.buildContext != null) {
      if (effects) {
        FlameAudio.play(audioName);
      }
    }
  }

  void stopMusic() {
    FlameAudio.bgm.stop();
  }
}
