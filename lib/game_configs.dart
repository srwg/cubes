import 'package:flutter/material.dart';
import 'constants.dart';
import 'block.dart';

/** Compute the board for a triangular board */
BigInt buildTriangleGameBoard() {
  var row = 1 << BOARD_W;
  var b = List<int>.generate(BOARD_W, (index) => row - (1 << (index + 1)));
  b[BOARD_W-1] = row - 1;
  var board = BigInt.zero;
  for (int r in b.reversed) {
  board = (board << BOARD_W) | BigInt.from(r);
  }
  return board;
}

/** Game configuration */
const GAME = [
  [-1, 0],
  [-1, 0],
  [0, 3],
  [-1, 0],
  [-1, 0],
  [22, 1],
  [-1, 0],
  [-1, 0],
  [-1, 0],
  [33, 2],
  [77, 7],
  [35, 3],
];

BigInt buildGame(BigInt board, List<Block> blocks, List<Block> blocks_home) {
  for (int i = 0; i < blocks.length; ++i) {
    if (GAME[i][0] >= 0) {
      blocks[i].setIndex(GAME[i][1]);
      board = blocks[i].place(GAME[i][0], board);
      blocks[i].is_fixed = true;
    } else {
      blocks_home.add(blocks[i]);
    }
  }
  return board;
}



