import 'package:flutter/material.dart';
import 'constants.dart';
import 'block.dart';

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

/** Block definitions */
const BLOCK_CONFIGS = [
  [Colors.yellow, [3, 3]],
  [Colors.red, [2, 7, 2]],
  [Colors.brown, [3, 1], [3, 2], [2, 3], [1, 3]],
  [Colors.greenAccent, [15], [1, 1, 1, 1]],
  [Colors.white, [7, 5], [3, 2, 3], [5, 7], [3, 1, 3]],
  [Colors.blue, [1, 1, 7], [7, 1, 1], [7, 4, 4], [4, 4, 7]],
  [Colors.orange, [1, 3, 6], [6, 3, 1], [3, 6, 4], [4, 6, 3]],
  [Colors.lightGreen, [1, 3, 1, 1], [15, 4], [2, 2, 3, 2], [2, 15],
  [15, 2], [2, 3, 2, 2], [4, 15], [1, 1, 3, 1]],
  [Colors.pink, [3, 1, 1, 1], [15, 8], [2, 2, 2, 3], [1, 15],
  [15, 1], [3, 2, 2, 2], [8, 15], [1, 1, 1, 3]],
  [Colors.purple, [2, 3, 1, 1], [7, 12], [2, 2, 3, 1], [3, 14],
  [14, 3], [1, 3, 2, 2], [12, 7], [1, 1, 3, 2]],
  [Colors.grey, [1, 1, 3], [7, 1], [3, 2, 2], [4, 7],
  [7, 4], [2, 2, 3], [1, 7], [3, 1, 1]],
  [Colors.cyan, [3, 3, 1], [7, 6], [2, 3, 3], [3, 7],
  [7, 3], [3, 3, 2], [6, 7], [1, 3, 3]],
];

Block buildBlock(List config, {is_fixed = false, is_placed = false, pos = 0}) {
  var g = BlockGroup();
  for (var proto in config.sublist(1)) {
    g.addBlock(BlockProto(proto));
  }
  return Block(g, config[0], is_fixed: is_fixed, is_placed: is_placed, pos: pos);
}





