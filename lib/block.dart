import './config.dart';
import 'package:flutter/material.dart';

class Block {
  final BlockGroup _group;
  final int _home;
  final Color color;
  int _g_index;
  BlockProto _block;
  bool _is_fixed;
  bool _is_placed;
  int pos;

  Block(this._group, this._home, this.color,
      {int index = 0, bool is_fixed = false, bool is_placed = false, int pos = 0}) {
    _g_index = index;
    _block = _group.get(_g_index);
    _is_fixed = is_fixed;
    _is_placed = is_placed;
    this.pos = pos;
  }

  bool isPlaced() => _is_placed;

  bool isSelected(int pos) {
    if (_is_fixed || !_is_placed || this.pos > pos) return false;
    return _block.getMask() >> (pos - this.pos) & BigInt.one != BigInt.zero;
  }

  BigInt place(int pos, BigInt board) {
    if (_is_placed || _block.getMask() << pos & board != BigInt.zero) {
      return board;
    }
    this.pos = pos;
    _is_placed = true;
    return board | (_block.getMask() << pos);
  }

  BigInt replace(BigInt board) {
    if (_is_fixed || !_is_placed) {
      return board;
    }
    _is_placed = false;
    return board - (_block.getMask() << this.pos);
  }

  BigInt rotate(BigInt board) {
    if (_is_fixed) {
      return board;
    }
    board = replace(board);
    _g_index++;
    _block = _group.get(_g_index);
    return board;
  }
}

// A immutable block with fixed rotation.
class BlockProto {
  final List<int> _proto;
  BigInt _mask;

  BlockProto(this._proto) {
    _mask = BigInt.from(0);
    for (int row in _proto.reversed) {
      _mask = (_mask << W) | BigInt.from(row);
    }
  }

  BigInt getMask() => _mask;

  List<int> getProto() => _proto;
}

// A block group contains a set of blocks that are connected through rotation.
class BlockGroup {
  final _blocks = List<BlockProto>();

  addBlock(BlockProto b) => _blocks.add(b);

  get(int index) => _blocks[index % _blocks.length];
}

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

Block buildFromConfig(List config, int home, {is_fixed = false, is_placed = false, pos = 0}) {
  var g = BlockGroup();
  for (var proto in config.sublist(1)) {
    g.addBlock(BlockProto(proto));
  }
  return Block(g, home, config[0], is_fixed: is_fixed, is_placed: is_placed, pos: pos);
}





