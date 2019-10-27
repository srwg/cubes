import 'package:flutter/material.dart';
import 'config.dart';
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
    blocks = BLOCK_CONFIGS.map((it) => buildFromConfig(it, 0)).toList();
    board = blocks[0].place(55, board);
    debugPrint(board.toRadixString(2));
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
    paintGameBoard(canvas, game.board);
    for (Block b in game.blocks) {
      paintPlacedBlock(canvas, b);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


/** Compute the board for a triangular board */
BigInt buildTriangleGameBoard() {
  var row = 1 << W;
  var b = List<int>.generate(W, (index) => row - (1 << (index + 1)));
  b[W-1] = row - 1;
  var board = BigInt.zero;
  for (int r in b.reversed) {
    board = (board << W) | BigInt.from(r);
  }
  return board;
}

void paintGameBoard(Canvas canvas, BigInt board) {
  var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey;
  for (int y = 0; y < W - 1; ++y) {
    for (int x = 0; x < W; ++x) {
      int pos = y * W + x;
      if (board >> pos & BigInt.one == BigInt.zero) {
        canvas.drawCircle(Offset(CS * (x + 0.5), DY + CS * (y + 0.5)), CS * 0.5, paint);
      }
    }
  }
}

void paintPlacedBlock(Canvas canvas, Block b) {
  if (!b.isPlaced()) return;
  var paint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = b.color;
  var pos = b.pos;
  var x = pos % W;
  var y = pos ~/ W;
  for 
}