import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:infinite_fall/game/game.dart';
import 'package:infinite_fall/overlay/go_menu.dart';
import 'package:infinite_fall/overlay/pause_button.dart';
import 'package:infinite_fall/overlay/pause_menu.dart';

InfiniteFall _infiniteFall = InfiniteFall();

class GameRunner extends StatelessWidget {
  const GameRunner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: GameWidget(
          game: _infiniteFall,
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, InfiniteFall game) =>
                PauseButton(
                  game: game,
                ),
            PauseMenu.id: (BuildContext context, InfiniteFall game) =>
                PauseMenu(
                  game: game,
                ),
            GameOverMenu.id: (BuildContext context, InfiniteFall game) =>
                GameOverMenu(
                  game: game,
                ),
          },
        ),
      ),
    );
  }
}
