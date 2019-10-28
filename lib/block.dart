import './constants.dart';
import 'package:flutter/material.dart';

class Block {
  final Color color;
  bool is_fixed;
  bool is_placed;
  int pos;

  final BlockGroup _group;
  int _g_index;
  BlockProto _block;

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
class BlockProto {
  final List<int> _proto;
  BigInt native_mask;
  BigInt mask;

  BlockProto(this._proto) {
    native_mask = _computeMask(BS);
    mask = _computeMask(W);
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
class BlockGroup {
  final _blocks = List<BlockProto>();

  addBlock(BlockProto b) => _blocks.add(b);

  get(int index) => _blocks[index % _blocks.length];
}