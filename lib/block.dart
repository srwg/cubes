import './constants.dart';
import 'package:flutter/material.dart';

class Block {
  final Color color;
  bool is_fixed;
  bool is_placed;
  int pos;

  final _BlockGroup _group;
  int _g_index;
  _BlockProto _block;

  Block(this._group, this.color,
      {int index = 0, bool is_fixed = false, bool is_placed = false, int pos = 0}) {
    _g_index = index;
    _block = _group.get(_g_index);
    this.is_fixed = is_fixed;
    this.is_placed = is_placed;
    this.pos = pos;
  }

  bool isSelected(int pos) {
    if (is_fixed || !is_placed || this.pos > pos) return false;
    return _block.mask >> (pos - this.pos) & BigInt.one != BigInt.zero;
  }

  BigInt getMask() {
    return is_placed ? _block.mask << pos: _block.native_mask;
  }

  BigInt place(int pos, BigInt board) {
    if (is_placed || _block.mask << pos & board != BigInt.zero) {
      return board;
    }
    this.pos = pos;
    is_placed = true;
    return board | (_block.mask << pos);
  }

  BigInt replace(BigInt board) {
    if (is_fixed || !is_placed) {
      return board;
    }
    is_placed = false;
    return board - (_block.mask << this.pos);
  }

  BigInt rotate(BigInt board) {
    if (is_fixed) {
      return board;
    }
    board = replace(board);
    _g_index++;
    _block = _group.get(_g_index);
    return board;
  }

  void setIndex(int i) {
    _g_index = i;
    _block = _group.get(_g_index);
  }
}

// A immutable block with fixed rotation.
class _BlockProto {
  final List<int> _proto;
  BigInt native_mask;
  BigInt mask;

  _BlockProto(this._proto) {
    native_mask = _computeMask(NATIVE_W);
    mask = _computeMask(BOARD_W);
  }

  BigInt _computeMask(int w) {
    var m = BigInt.zero;
    for (int row in _proto.reversed) {
      m = (m << w) | BigInt.from(row);
    }
    return m;
  }
}

// A block group contains a set of blocks that are connected through rotation.
class _BlockGroup {
  final _blocks = List<_BlockProto>();

  addBlock(_BlockProto b) => _blocks.add(b);

  get(int index) => _blocks[index % _blocks.length];
}

/** Block definitions */
const _BLOCK_CONFIGS = [
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

Block _buildBlock(List config, {is_fixed = false, is_placed = false, pos = 0}) {
  var g = _BlockGroup();
  for (var proto in config.sublist(1)) {
    g.addBlock(_BlockProto(proto));
  }
  return Block(g, config[0], is_fixed: is_fixed, is_placed: is_placed, pos: pos);
}

List<Block> buildBlocks() => _BLOCK_CONFIGS.map((it) => _buildBlock(it)).toList();