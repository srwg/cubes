import 'package:flutter/material.dart';
import 'constants.dart';
import 'game_configs.dart';
import 'block.dart';

// The pixel diameter size of a circle
const CIRCLE_D = 20;

// The pixel size of a home block
const NATIVE_D = CIRCLE_D * NATIVE_W;

// The Y positions for each section
const Y0 = 50;
const Y1 = Y0 + CIRCLE_D * BOARD_W;
const Y2 = Y1 + 50;

class GameWidget extends StatelessWidget {
  final GamePainter painter = GamePainter();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
          size: Size(NATIVE_D * 4.0, Y2 + NATIVE_D * 2.0),
          painter: painter,
          isComplex: true,
          willChange: true),
      onTapUp: (TapUpDetails d) => painter.onRotate(d.localPosition),
      onPanStart: (DragStartDetails d) => painter.onDragBegin(d.localPosition),
      onPanUpdate: (DragUpdateDetails d) => painter.onDragUpdate(d.localPosition),
      onPanEnd: (DragEndDetails d) => painter.onDragEnd(),
    );
  }
}

class GamePainter extends ChangeNotifier implements CustomPainter {
  BigInt board;
  List<Block> blocks;
  final List<Block> home_blocks = [];
  Block moving_block;
  Offset pos;

  GamePainter() {
    board = buildTriangleGameBoard();
    blocks = buildBlocks();
    board = buildGame(board, blocks, home_blocks);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _paintInBoard(board, Colors.white24, canvas, paint, target: 0);
    for (Block block in blocks) {
      if (block.is_placed) {
        _paintInBoard(block.getMask(), block.color, canvas, paint);
      }
    }
    for (int y = 0; y < 2; ++y) {
      for (int x = 0; x < 4; ++x) {
        if (y * 4 + x >= home_blocks.length) continue;
        Block b = home_blocks[y * 4 + x];
        if (!b.is_placed && b != moving_block) {
          _paintAtXY(b.getMask(), b.color, canvas, paint, x * NATIVE_D, Y2 + y * NATIVE_D);
        }
      }
    }
    Block b = moving_block;
    if (b != null) {
      _paintAtXY(b.getMask(), b.color, canvas, paint, pos.dx.toInt() - CIRCLE_D ~/2,
          pos.dy.toInt() - CIRCLE_D ~/2);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _paintInBoard(BigInt mask, Color color, Canvas canvas, Paint paint,
      {int target = 1}) {
    paint.color = color;
    for (int y = 0; y < BOARD_W - 1; ++y) {
      for (int x = 0; x < BOARD_W; ++x) {
        int pos = y * BOARD_W + x;
        if (mask >> pos & BigInt.one == BigInt.from(target)) {
          canvas.drawCircle(
              Offset(CIRCLE_D * (x + 0.5), Y0 + CIRCLE_D * (y + 0.5)), CIRCLE_D * 0.5, paint);
        }
      }
    }
  }

  void _paintAtXY(
      BigInt mask, Color color, Canvas canvas, Paint paint, int dx, int dy) {
    paint.color = color;
    for (int y = 0; y < NATIVE_W; ++y) {
      for (int x = 0; x < NATIVE_W; ++x) {
        int pos = y * NATIVE_W + x;
        if (mask >> pos & BigInt.one == BigInt.one) {
          canvas.drawCircle(Offset(dx + CIRCLE_D * (x + 0.5), dy + CIRCLE_D * (y + 0.5)),
              CIRCLE_D * 0.5, paint);
        }
      }
    }
  }

  Block _findSelected(Offset offset) {
    if (offset.dy >= Y2) {
      // search in home area.
      int iy = (offset.dy - Y2).toInt() ~/ NATIVE_D;
      int ix = offset.dx.toInt() ~/ NATIVE_D;
      int home = iy * 4 + ix;
      return home < home_blocks.length && !home_blocks[home].is_placed
          ? home_blocks[home] :  null;
    } else if (offset.dy >= Y0 && offset.dy < Y1) {
      int iy = (offset.dy - Y0).toInt() ~/ CIRCLE_D;
      int ix = offset.dx.toInt() ~/ CIRCLE_D;
      int pos = iy * BOARD_W + ix;
      for (Block b in blocks) {
        if (b.is_placed && !b.is_fixed && b.isSelected(pos)) {
          debugPrint(b.color.toString());
          return b;
        }
      }
    }
    return null;
  }

  void onRotate(Offset offset) {
    Block b = _findSelected(offset);
    if (b != null) {
      board = b.rotate(board);
      notifyListeners();
    }
  }

  void onDragBegin(Offset offset) {
    pos = offset;
    moving_block = _findSelected(offset);
    if (moving_block != null) {
      board = moving_block.replace(board);
    }
  }

  void onDragUpdate(Offset offset) {
    pos = offset;
    notifyListeners();
  }

  void onDragEnd() {
    if (moving_block != null) {
      if (pos.dy >= Y0 && pos.dy < Y1) {
        int iy = (pos.dy - Y0).toInt() ~/ CIRCLE_D;
        int ix = pos.dx.toInt() ~/ CIRCLE_D;
        int p = iy * BOARD_W + ix;
        board = moving_block.place(p, board);
      } else {
        board = moving_block.replace(board);
      }
      moving_block = null;
      notifyListeners();
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
