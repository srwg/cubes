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
  final List<Block> blocks_home = [];
  Block moving_block;
  Offset pos;
  GamePainter painter;

  @override
  void initState() {
    super.initState();
    board = buildTriangleGameBoard();
    blocks = BLOCK_CONFIGS.map((it) => buildBlock(it)).toList();
    board = buildGame(board, blocks, blocks_home);
    painter = GamePainter(this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
          size: Size(800, 1000),
          painter: painter,
          isComplex: true,
          willChange: true),
      onTapUp: (TapUpDetails d) => _onRotate(d.localPosition),
      onPanStart: (DragStartDetails d) => _onDragBegin(d.localPosition),
      onPanUpdate: (DragUpdateDetails d) => _onDragUpdate(d.localPosition),
      onPanEnd: (DragEndDetails d) => _onDragEnd(),
    );
  }

  Block _findSelected(Offset offset) {
    if (offset.dy >= Y2) {
      // search in home area.
      int iy = (offset.dy - Y2).toInt() ~/ HS;
      int ix = offset.dx.toInt() ~/ HS;
      int home = iy * 4 + ix;
      return home < blocks_home.length && !blocks_home[home].is_placed
          ? blocks_home[home] :  null;
    } else if (offset.dy >= Y0 && offset.dy < Y1) {
      int iy = (offset.dy - Y0).toInt() ~/ CS;
      int ix = offset.dx.toInt() ~/ CS;
      int pos = iy * W + ix;
      for (Block b in blocks) {
        if (b.is_placed && !b.is_fixed && b.isSelected(pos)) {
          debugPrint(b.color.toString());
          return b;
        }
      }
    }
    return null;
  }

  _onRotate(Offset offset) {
    Block b = _findSelected(offset);
    if (b != null) {
      board = b.rotate(board);
      painter.notifyListeners();
    }
  }

  _onDragBegin(Offset offset) {
    pos = offset;
    moving_block = _findSelected(offset);
    if (moving_block != null) {
      board = moving_block.replace(board);
    }
  }

  _onDragUpdate(Offset offset) {
    pos = offset;
    painter.notifyListeners();
  }

  _onDragEnd() {
    if (moving_block != null) {
      if (pos.dy >= Y0 && pos.dy < Y1) {
        int iy = (pos.dy - Y0).toInt() ~/ CS;
        int ix = pos.dx.toInt() ~/ CS;
        int p = iy * W + ix;
        board = moving_block.place(p, board);
      } else {
        board = moving_block.replace(board);
      }
      moving_block = null;
      painter.notifyListeners();
    }
  }
}

class GamePainter extends ChangeNotifier implements CustomPainter {
  final Game game;

  GamePainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintInBoard(game.board, Colors.white24, canvas, paint, target: 0);
    for (Block block in game.blocks) {
      if (block.is_placed) {
        _paintInBoard(block.getMask(), block.color, canvas, paint);
      }
    }
    for (int y = 0; y < 2; ++y) {
      for (int x = 0; x < 4; ++x) {
        if (y * 4 + x >= game.blocks_home.length) continue;
        Block b = game.blocks_home[y * 4 + x];
        if (!b.is_placed) {
          _paintAtXY(b.getMask(), b.color, canvas, paint, x * HS, Y2 + y * HS);
        }
      }
    }
    Block b = game.moving_block;
    if (b != null) {
      _paintAtXY(b.getMask(), b.color, canvas, paint, game.pos.dx.toInt() - CS ~/2,
          game.pos.dy.toInt() - CS ~/2);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _paintInBoard(BigInt mask, Color color, Canvas canvas, Paint paint,
      {int target = 1}) {
    paint.color = color;
    for (int y = 0; y < W - 1; ++y) {
      for (int x = 0; x < W; ++x) {
        int pos = y * W + x;
        if (mask >> pos & BigInt.one == BigInt.from(target)) {
          canvas.drawCircle(
              Offset(CS * (x + 0.5), Y0 + CS * (y + 0.5)), CS * 0.5, paint);
        }
      }
    }
  }

  void _paintAtXY(
      BigInt mask, Color color, Canvas canvas, Paint paint, int dx, int dy) {
    paint.color = color;
    for (int y = 0; y < BS; ++y) {
      for (int x = 0; x < BS; ++x) {
        int pos = y * BS + x;
        if (mask >> pos & BigInt.one == BigInt.one) {
          canvas.drawCircle(Offset(dx + CS * (x + 0.5), dy + CS * (y + 0.5)),
              CS * 0.5, paint);
        }
      }
    }
  }

  @override
  bool hitTest(Offset p) => null;

  @override
  // TODO: implement semanticsBuilder
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    // TODO: implement shouldRebuildSemantics
    return true;
  }
}
