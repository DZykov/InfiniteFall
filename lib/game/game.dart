import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/services.dart';
import 'package:infinite_fall/game/audio.dart';
import 'package:infinite_fall/game/block.dart';
import 'package:infinite_fall/game/block_manager.dart';
import 'package:infinite_fall/game/player.dart';
import 'package:infinite_fall/game/powerup.dart';
import 'package:infinite_fall/game/powerup_manager.dart';
import 'package:infinite_fall/overlay/go_menu.dart';
import 'package:infinite_fall/overlay/pause_button.dart';
import 'package:infinite_fall/overlay/pause_menu.dart';

class InfiniteFall extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
  double powerSpeed = 50;
  double blockSpeed = 100;
  int elapsedSecs = 1;
  int onePeriod = 100;
  final Vector2 spriteSize = Vector2(32, 32);
  final double blockSpeedAcceleration = 2;
  final double joystickRadius = 60;
  final double joystickInnerRadius = 20;
  final double joystickDeadZone = 10;
  late Player player;
  Offset? _pointerStartPosition;
  Offset? _pointerCurrentPosition;
  late BlockManager _blockManager;
  late PowerManager _powerManager;
  late Timer interval;
  late TextComponent _playerScore;
  late TextComponent _playerHealth;
  late Audio audio;

  @override
  FutureOr<void> onLoad() async {
    debugMode = false;

    audio = Audio();
    add(audio);

    await images.load('monochrome_tilemap_transparent_packed.png');
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('monochrome_tilemap_transparent_packed.png'),
        columns: 20,
        rows: 20);

    Vector2 screenSize = camera.viewport.canvasSize!;

    final stars = await ParallaxComponent.load(
      [ParallaxImageData('stars1.png'), ParallaxImageData('stars2.png')],
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, 50),
      velocityMultiplierDelta: Vector2(0, 1.5),
      size: screenSize,
    );
    add(stars);

    player = Player(
        spriteSheet: spriteSheet,
        size: spriteSize,
        position: Vector2(screenSize.x / 2, screenSize.y / 5));
    player.anchor = Anchor.center;
    add(player);

    _blockManager = BlockManager(
        spriteSheet: spriteSheet,
        spriteIds: [63, 83, 103, 123, 143, 163],
        size: spriteSize,
        speed: blockSpeed);
    add(_blockManager);

    _powerManager = PowerManager(
        spriteSheet: spriteSheet,
        spriteIds: [20, 21, 41, 48, 62, 102],
        size: spriteSize,
        speed: powerSpeed);
    add(_powerManager);

    interval = Timer(
      1,
      onTick: () => elapsedSecs += 1,
      repeat: true,
    );

    _playerScore = TextComponent(
      text: 'Score: $elapsedSecs',
      position: Vector2(screenSize.x - 10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
    _playerScore.positionType = PositionType.viewport;
    _playerScore.anchor = Anchor.topRight;
    add(_playerScore);

    _playerHealth = TextComponent(
      text: 'Health: ${player.health}',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
    _playerHealth.positionType = PositionType.viewport;
    add(_playerHealth);

    overlays.add(PauseButton.id);
  }

  @override
  void onAttach() {
    audio.playMusic('music.mp3');
    super.onAttach();
  }

  @override
  void onDetach() {
    audio.stopMusic();
    super.onDetach();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    if (elapsedSecs % onePeriod == 0) {
      _blockManager.increaseSpeed(blockSpeedAcceleration);
    }

    if (player.isMounted) {
      _playerScore.text = 'Score: $elapsedSecs';
      _playerHealth.text = 'Health: ${player.health}';

      if (player.health <= 0) {
        pauseEngine();
        overlays.remove(PauseButton.id);
        overlays.add(GameOverMenu.id);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_pointerStartPosition != null) {
      canvas.drawCircle(_pointerStartPosition!, joystickRadius,
          Paint()..color = Colors.grey.withAlpha(100));
    }

    if (_pointerCurrentPosition != null) {
      var delta = _pointerCurrentPosition! - _pointerStartPosition!;

      if (delta.distance > joystickRadius) {
        delta = _pointerStartPosition! +
            (Vector2(delta.dx, delta.dy).normalized() * joystickRadius)
                .toOffset();
      } else {
        delta = _pointerCurrentPosition!;
      }

      canvas.drawCircle(delta, joystickInnerRadius,
          Paint()..color = Colors.white.withAlpha(100));
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  void reset() {
    Vector2 screenSize = camera.viewport.canvasSize!;
    player.reset(Vector2(screenSize.x / 2, screenSize.y / 5));
    _powerManager.reset();
    _blockManager.reset(blockSpeed);
    powerSpeed = 50;
    blockSpeed = 100;
    elapsedSecs = 1;
    onePeriod = 100;
    children.whereType<BlockE>().forEach((block) {
      block.removeFromParent();
    });
    children.whereType<Power>().forEach((power) {
      power.removeFromParent();
    });
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        player.setMoveDirection(Vector2(0, -1));
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        player.setMoveDirection(Vector2(0, 1));
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        player.setMoveDirection(Vector2(-1, 0));
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        player.setMoveDirection(Vector2(1, 0));
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void onPanStart(DragStartInfo info) {
    _pointerStartPosition = info.raw.globalPosition;
    _pointerCurrentPosition = info.raw.globalPosition;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _pointerCurrentPosition = info.raw.globalPosition;

    var delta = _pointerCurrentPosition! - _pointerStartPosition!;

    if (delta.distance > joystickDeadZone) {
      player.setMoveDirection(Vector2(delta.dx, delta.dy));
    } else {
      player.setMoveDirection(Vector2.zero());
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
  }

  @override
  void onPanCancel() {
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
  }
}
