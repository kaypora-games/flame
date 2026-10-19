import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlameGame extends Mock implements FlameGame {}

class _MockBuildContext extends Mock implements BuildContext {}

/// A game that can decide whether it wants to be repainted after an update.
class _ThrottledGame extends FlameGame {
  bool paintAfterUpdate = true;
  int updates = 0;

  @override
  bool get needsPaint => paintAfterUpdate;

  @override
  void update(double dt) {
    updates++;
    super.update(dt);
  }
}

/// Counts how many times the render box asked Flutter to repaint it.
class _CountingGameRenderBox extends GameRenderBox {
  _CountingGameRenderBox(super.game, super.buildContext)
    : super(isRepaintBoundary: false);

  int paintRequests = 0;

  @override
  void markNeedsPaint() {
    paintRequests++;
    super.markNeedsPaint();
  }
}

final _nodesNeedingCompositingBitsUpdate = <RenderObject>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_nodesNeedingCompositingBitsUpdate.clear);

  group('GameRenderBox', () {
    test('game/attach', () {
      final owner = PipelineOwner();
      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      verify(() => game.attach(owner, renderBox)).called(1);
      expect(renderBox.gameLoop, isNotNull);
      verify(() => game.paused).called(1);

      final anotherGame = _MockFlameGame();
      when(() => anotherGame.paused).thenReturn(true);

      renderBox.game = anotherGame;
      verify(game.detach).called(1);
      verify(() => anotherGame.attach(owner, renderBox)).called(1);
      verify(() => anotherGame.paused).called(1);
      expect(renderBox.gameLoop, isNotNull);
    });

    test('buildContext', () {
      final owner = PipelineOwner();
      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      expect(renderBox.buildContext, context);
    });

    test('isRepaintBoundary', () {
      final owner = PipelineOwner();

      final game = _MockFlameGame();
      when(() => game.paused).thenReturn(true);

      final BuildContext context = _MockBuildContext();
      final renderBox = GameRenderBox(game, context, isRepaintBoundary: false);
      renderBox.attach(owner);

      expect(renderBox.isRepaintBoundary, false);

      renderBox.isRepaintBoundary = true;

      expect(renderBox.isRepaintBoundary, true);
    });

    test('gameLoopCallback repaints on every tick by default', () {
      final game = FlameGame()..pauseEngine();
      final BuildContext context = _MockBuildContext();
      final renderBox = _CountingGameRenderBox(game, context);
      renderBox.attach(PipelineOwner());

      renderBox.gameLoopCallback(0.016);
      renderBox.gameLoopCallback(0.016);

      expect(renderBox.paintRequests, 2);
      renderBox.detach();
    });

    test('gameLoopCallback skips markNeedsPaint when the game does not need '
        'to be painted', () {
      final game = _ThrottledGame()..pauseEngine();
      final BuildContext context = _MockBuildContext();
      final renderBox = _CountingGameRenderBox(game, context);
      renderBox.attach(PipelineOwner());

      game.paintAfterUpdate = false;
      renderBox.gameLoopCallback(0.016);
      renderBox.gameLoopCallback(0.016);

      // The game is still updated on every tick, it is only not repainted.
      expect(game.updates, 2);
      expect(renderBox.paintRequests, 0);

      game.paintAfterUpdate = true;
      renderBox.gameLoopCallback(0.016);

      expect(game.updates, 3);
      expect(renderBox.paintRequests, 1);
      renderBox.detach();
    });
  });
}
