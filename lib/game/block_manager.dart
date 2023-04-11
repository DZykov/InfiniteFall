import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flame/components.dart';

import 'block.dart';

class BlockManager extends Component with HasGameRef {
  double spawnBlockTime = 0.4;
  double freezeTime = 5;

  late Timer _timer;
  late Timer _freezeTimer;

  SpriteSheet spriteSheet;
  List<int> spriteIds;
  double speed;
  Vector2 size;

  Random random = Random();

  BlockManager(
      {required this.spriteSheet,
      required this.spriteIds,
      required this.size,
      required this.speed})
      : super() {
    _timer = Timer(spawnBlockTime, onTick: _spawnBlock, repeat: true);
    _freezeTimer = Timer(freezeTime, onTick: () {
      _timer.start();
    });
  }

  void _spawnBlock() {
    Vector2 position = Vector2(random.nextDouble() * game.size.x, game.size.y);

    if (game.buildContext != null) {
      BlockE block = BlockE(
        sprite: spriteSheet
            .getSpriteById(spriteIds[random.nextInt(spriteIds.length)]),
        size: size,
        speed: speed,
        position: position,
      );
      block.anchor = Anchor.center;
      game.add(block);
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

  void reset(double blockSpeed) {
    speed = blockSpeed;
    _timer.stop();
    _timer.start();
  }

  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  void increaseSpeed(double addon) {
    speed = speed + addon;
  }
}
