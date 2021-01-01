import 'dart:math' as math;

void main() {
  final board = <List<int>>[
    [1, 2, 3, 4, 5, 6], // 0: 0x black (player1) home, 1x white (player2) bar
    [], // 1: 2x white (player2)
    [], // 2
    [], // 3
    [], // 4
    [], // 5
    [-14, -13, -12, -11], // 6: 5x black (player1)
    [], // 7
    [-10, -9, -8], // 8: 3x black (player1)
    [], // 9
    [], // 10
    [], // 11
    [7], // 12: 5x white (player2)
    [-7, -6, -5, -4, -3], // 13: 5x black (player1)
    [], // 14
    [], // 15
    [], // 16
    [8, 9, 10], // 17: 3x white (player2)
    [], // 18
    [11, 12, 13, 14, 15], // 19: 5x white (player2)
    [], // 20
    [], // 21
    [], // 22
    [], // 23
    [-1, -2], // 24: 2x black (player1)
    [-15], // 25: 2x black (player1) bar, 0x white (player2) home
  ];

  print(boardToString(board));
}

String boardToString(List<List<int>> board) {
  final lines = List<String>.filled(13, null);
  lines[00] = '+13-14-15-16-17-18-+---+-19-20-21-22-23-24-+---+';
  lines[01] = '|                  |   |                   |   |';
  lines[02] = '|                  |   |                   |   |';
  lines[03] = '|                  |   |                   |   |';
  lines[04] = '|                  |   |                   |   |';
  lines[05] = '|                  |   |                   |   |';
  lines[06] = '|                  |   |                   |   |';
  lines[07] = '|                  |   |                   |   |';
  lines[08] = '|                  |   |                   |   |';
  lines[09] = '|                  |   |                   |   |';
  lines[10] = '|                  |   |                   |   |';
  lines[11] = '|                  |   |                   |   |';
  lines[12] = '+12-11-10--9--8--7-+---+--6--5--4--3--2--1-+---+';

  // make sure we got 'em all
  final foundPieceIDs = List<List<bool>>.generate(2, (_) => List<bool>.filled(15, false));
  void found(int pieceID) {
    assert(pieceID.abs() >= 1 && pieceID.abs() <= 15);
    assert(!foundPieceIDs[pieceID < 0 ? 0 : 1][pieceID.abs() - 1], 'duplicate pieceID: $pieceID');
    foundPieceIDs[pieceID < 0 ? 0 : 1][pieceID.abs() - 1] = true;
  }

  // board pips
  for (var pip = 1; pip != 25; ++pip) {
    final pieces = board[pip].length;
    if (pieces == 0) continue;

    final color = board[pip][0] < 0 ? 'X' : 'O';

    for (final pieceID in board[pip]) {
      assert(pieceID.sign == board[pip][0].sign);
      found(pieceID);
    }

    if (pip >= 13 && pip <= 18) {
      for (var i = 0; i != math.min(pieces, 5); ++i) {
        lines[i + 1] = lines[i + 1].replaceAt(5 + (pip - 10) * 3, color);
      }

      if (pieces > 5) {
        final pileup = pieces.toString();
        lines[4 + 1] = lines[4 + 1].replaceAt(2 + (pip - 13) * 3, pileup);
        assert(pileup.length == 1, 'Not handling two-digit pileups');
      }
    } else if (pip >= 19 && pip <= 24) {
      for (var i = 0; i != math.min(pieces, 5); ++i) {
        lines[i + 1] = lines[i + 1].replaceAt(26 + (pip - 19) * 3, color);
      }

      if (pieces > 5) {
        final pileup = pieces.toString();
        lines[4 + 1] = lines[4 + 1].replaceAt(26 + (pip - 19) * 3, pileup);
        assert(pileup.length == 1, 'Not handling two-digit pileups');
      }
    } else if (pip >= 1 && pip <= 6) {
      for (var i = 0; i != math.min(pieces, 5); ++i) {
        lines[11 - i] = lines[11 - i].replaceAt(41 - (pip - 1) * 3, color);
      }

      if (pieces > 5) {
        final pileup = pieces.toString();
        lines[8 - 1] = lines[8 - 1].replaceAt(41 - (pip - 1) * 3, pileup);
        assert(pileup.length == 1, 'Not handling two-digit pileups');
      }
    } else if (pip >= 7 && pip <= 12) {
      for (var i = 0; i != math.min(pieces, 5); ++i) {
        lines[11 - i] = lines[11 - i].replaceAt(17 - (pip - 7) * 3, color);
      }

      if (pieces > 5) {
        final pileup = pieces.toString();
        lines[8 - 1] = lines[8 - 1].replaceAt(17 - (pip - 7) * 3, pileup);
        assert(pileup.length == 1, 'Not handling two-digit pileups');
      }
    } else {
      assert(false, 'pip out of range: $pip');
    }
  }

  // player1 home
  // TODO

  // player2 home
  // TODO

  // player1 bar
  {
    final pieces = board[25].where((pid) => pid < 0).length;
    for (final pieceID in board[25].where((pid) => pid < 0)) {
      found(pieceID);
    }

    for (var x = 0; x != math.min(pieces, 5); ++x) {
      lines[x + 1] = lines[x + 1].replaceAt(21, 'X');
    }

    if (pieces > 5) {
      final pileup = pieces.toString();
      lines[4 + 1] = lines[4 + 1].replaceAt(21, pileup);
      assert(pileup.length == 1, 'Not handling two-digit pileups');
    }
  }

  // player2 bar
  {
    final pieces = board[0].where((pid) => pid > 0).length;
    for (final pieceID in board[0].where((pid) => pid > 0)) {
      found(pieceID);
    }

    for (var o = 0; o != math.min(pieces, 5); ++o) {
      lines[11 - o] = lines[11 - o].replaceAt(21, 'O');
    }

    if (pieces > 5) {
      final pileup = pieces.toString();
      lines[8 - 1] = lines[8 - 1].replaceAt(21, pileup);
      assert(pileup.length == 1, 'Not handling two-digit pileups');
    }
  }

  assert(foundPieceIDs.length == 2);
  for (var i = 0; i != 2; ++i) {
    assert(foundPieceIDs[i].length == 15);
    for (var j = 0; j != 15; ++j) {
      final pieceID = i == 0 ? -(j + 1) : j + 1;
      assert(foundPieceIDs[i][j], 'missing pieceID: $pieceID');
    }
  }

  return lines.join('\n');
}

extension on String {
  String replaceAt(int index, String s) => substring(0, index) + s + substring(index + 1);
}
