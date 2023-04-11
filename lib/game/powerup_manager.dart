import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:infinite_fall/game/powerup.dart';

class PowerManager extends Component with HasGameRef {
  double spawnPowerTime = 15;
  double freezeTime = 2;

  late Timer _timer;
  late Timer _freezeTimer;

  SpriteSheet spriteSheet;
  List<int> spriteIds;
  double speed;
  Vector2 size;

  Random random = Random();

  PowerManager(
      {required this.spriteSheet,
      required this.spriteIds,
      required this.size,
      required this.speed})
      : super() {
    _timer = Timer(spawnPowerTime, onTick: _spawnPower, repeat: true);
    _freezeTimer = Timer(freezeTime, onTick: () {
      _timer.start();
    });
  }

  void _spawnPower() {
    Vector2 position = Vector2(random.nextDouble() * game.size.x, game.size.y);

    if (game.buildContext != null) {
      int index = random.nextInt(spriteIds.length);
      int id = spriteIds[index];
      Power power = Power(
        sprite: spriteSheet.getSpriteById(spriteIds[index]),
        size: size,
        speed: speed,
        position: position,
        id: id,
      );
      power.anchor = Anchor.center;
      game.add(power);
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset() {
    _timer.stop();
    _timer.start();
  }

  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
