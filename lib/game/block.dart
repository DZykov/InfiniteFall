import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:infinite_fall/game/audio.dart';
import 'package:infinite_fall/game/player.dart';

class BlockE extends SpriteComponent with CollisionCallbacks, HasGameRef {
  double _speed = 0;
  double freezeTime = 5;
  Audio audio = Audio();

  Vector2 moveDirection = Vector2(0, -1);

  late final SpriteSheet spriteSheet;
  late Timer _freezeTimer;

  final _random = Random();

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1)).normalized();
  }

  BlockE({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required double speed,
  }) : super(sprite: sprite, position: position, size: size, priority: 1) {
    _speed = speed;
    add(audio);
    _freezeTimer = Timer(freezeTime, onTick: () {
      _speed = speed;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    _freezeTimer.update(dt);

    position += moveDirection * _speed * dt;

    if (position.y <= 0) {
      removeFromParent();
    }
  }

  @override
  void onMount() {
    super.onMount();
    final shape = RectangleHitbox.relative(Vector2(1, 1),
        parentSize: size * 0.9, position: size / 2, anchor: Anchor.center);
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      other.position.y -= 25;
      final particleDeath = ParticleSystemComponent(
        particle: Particle.generate(
          count: 5,
          lifespan: 0.2,
          generator: (i) => AcceleratedParticle(
            acceleration: getRandomVector(),
            speed: getRandomVector(),
            position: other.position.clone(),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = Colors.red,
            ),
          ),
        ),
      );
      audio.playSfx('block_hit.wav');
      game.add(particleDeath);
    }
  }

  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
