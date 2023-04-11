import 'package:flutter/material.dart';
import 'package:infinite_fall/game/game.dart';
import 'package:infinite_fall/overlay/pause_menu.dart';

class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final InfiniteFall game;

  const PauseButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          game.pauseEngine();
          game.overlays.add(PauseMenu.id);
          game.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
