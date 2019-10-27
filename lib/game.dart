import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_configs.dart';
import 'block.dart';

class GameWidget extends StatefulWidget {
  @override
  Game createState() => Game();
}

class Game extends State<GameWidget> {
  BigInt board;
  List<Block> blocks;

  @override
  void initState() {
    board = buildTriangleGameBoard();
    blocks = BLOCK_CONFIGS.map((it) => buildBlock(it)).toList();
    // TODO place initial blocks...
    board = blocks[0].place(55, board);
  }

  @override
  Widget build(BuildContext context) =>
    CustomPaint(
        size: Size(800, 1000),
        painter: GamePainter(this),
        isComplex: true,
        willChange: true);
}

class GamePainter extends CustomPainter {
  final Game game;

  GamePainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintInBoard(game.board, Colors.blueGrey, canvas, paint, target: 0);
    for (Block block in game.blocks) {
      if (block.is_placed) {
        _paintInBoard(block.getMask(), block.color, canvas, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _paintInBoard(BigInt mask, Color color, Canvas canvas, Paint paint, {int target = 1}) {
    paint.color = color;
    for (int y = 0; y < W - 1; ++y) {
      for (int x = 0; x < W; ++x) {
        int pos = y * W + x;
        if (mask >> pos & BigInt.one == BigInt.from(target)) {
          canvas.drawCircle(Offset(CS * (x + 0.5), DY + CS * (y + 0.5)), CS * 0.5, paint);
        }
      }
    }
  }
}
