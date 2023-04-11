import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:infinite_fall/game/block.dart';

import 'powerup.dart';

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef {
  Vector2 _moveDirection = Vector2.zero();
  double powerDuration = 4;
  double _speed = 150;
  bool mortal = true;
  bool moveUp = false;
  bool flipped = false;
  double health = 3;
  final double _animationSpeed = 0.2;

  final _random = Random();
  late final SpriteSheet spriteSheet;
  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  late final SpriteAnimation _standingAnimation;
  late Timer _powerTimer;

  Player({
    required Vector2 size,
    required Vector2 position,
    required this.spriteSheet,
  }) : super(
          size: size,
          position: position,
          priority: 1,
        ) {
    _powerTimer = Timer(powerDuration, onTick: () {
      mortal = true;
      moveUp = false;
      add(
        ColorEffect(
          const Color.fromARGB(255, 255, 255, 255),
          const Offset(0.0, 0.8),
          EffectController(duration: powerDuration / 2),
        ),
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerTimer.update(dt);
    position += _moveDirection.normalized() * _speed * dt;
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 5,
        lifespan: 0.2,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: position.clone(),
          child: CircleParticle(
            radius: 10,
            paint: Paint()..color = Colors.blue,
          ),
        ),
      ),
    );

    game.add(particleComponent);
  }

  void reset(Vector2 newPosition) {
    health = 3;
    _speed = 150;
    position = newPosition;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations().then((_) => {animation = _standingAnimation});
  }

  @override
  void onMount() {
    super.onMount();
    final shape = RectangleHitbox.relative(Vector2(1, 1),
        parentSize: size, position: size / 2, anchor: Anchor.center);
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is BlockE && mortal) {
      health--;
      mortal = false;
      add(
        ColorEffect(
          const Color.fromARGB(255, 255, 0, 0),
          const Offset(0.5, 0.8),
          EffectController(duration: powerDuration),
        ),
      );
      _powerTimer.stop();
      _powerTimer.start();
    }
    if (other is Power) {
      if (other.getId() == 20) {
        position.y -= 50;
      }
      if (other.getId() == 21) {
        position.y -= 50;
      }
      if (other.getId() == 41) {
        if (health <= 5) {
          health++;
        }
      }
      if (other.getId() == 48) {
        moveUp = true;
        _powerTimer.stop();
        _powerTimer.start();
      }
      if (other.getId() == 62) {
        _speed += 50;
      }
      if (other.getId() == 102) {
        mortal = false;
        add(
          ColorEffect(
            const Color.fromARGB(255, 255, 238, 0),
            const Offset(0.5, 0.8),
            EffectController(duration: powerDuration),
          ),
        );
        _powerTimer.stop();
        _powerTimer.start();
      }
    }
  }

  Future<void> _loadAnimations() async {
    _runDownAnimation = spriteSheet.createAnimation(
        row: 15, stepTime: _animationSpeed, from: 5, to: 6);
    _runUpAnimation = spriteSheet.createAnimation(
        row: 15, stepTime: _animationSpeed, from: 5, to: 6);
    _runLeftAnimation = spriteSheet.createAnimation(
        row: 15, stepTime: _animationSpeed, from: 0, to: 4);
    _runRightAnimation = spriteSheet.createAnimation(
        row: 15, stepTime: _animationSpeed, from: 0, to: 4);
    _standingAnimation = spriteSheet.createAnimation(
        row: 15, stepTime: _animationSpeed, from: 5, to: 6);

    _runUpAnimation.loop = false;
    _runDownAnimation.loop = false;
    _runLeftAnimation.loop = false;
    _runRightAnimation.loop = false;
    _standingAnimation.loop = false;
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    if (newMoveDirection.y >= 0) {
      _moveDirection = newMoveDirection;
    } else if (newMoveDirection.y < 0 && moveUp == true) {
      _moveDirection = newMoveDirection;
    } else if (newMoveDirection.y < 0) {
      _moveDirection = Vector2(newMoveDirection.x, 0);
    }
    // animations states
    if (newMoveDirection.y < 0 && newMoveDirection.x == 0) {
      animation = _runDownAnimation;
    } else if (newMoveDirection.y >= 0 && newMoveDirection.x == 0) {
      animation = _runUpAnimation;
    } else if (newMoveDirection.x >= 0) {
      animation = _runRightAnimation;
      if (flipped) {
        flipped = false;
        flipHorizontally();
      }
    } else if (newMoveDirection.x < 0) {
      animation = _runLeftAnimation;
      if (!flipped) {
        flipped = true;
        flipHorizontally();
      }
    }
  }

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, 1)) * 100;
  }
}
