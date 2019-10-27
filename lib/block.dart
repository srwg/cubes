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
    return _block.getMask() >> (pos - this.pos) & BigInt.one != BigInt.zero;
  }

  BigInt getMask() {
    return is_placed ? _block.getMask() << pos: BigInt.zero;
  }

  BigInt place(int pos, BigInt board) {
    if (is_placed || _block.getMask() << pos & board != BigInt.zero) {
      return board;
    }
    this.pos = pos;
    is_placed = true;
    return board | (_block.getMask() << pos);
  }

  BigInt replace(BigInt board) {
    if (is_fixed || !is_placed) {
      return board;
    }
    is_placed = false;
    return board - (_block.getMask() << this.pos);
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