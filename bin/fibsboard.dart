import 'dart:math' as math;
import 'package:dartx/dartx.dart';

void main() {
  final board = <List<int>>[
    [-14, -13, -12, -11, -10, -9, -8], // 0: 0x black (player1) off, 1x white (player2) bar
    [-1, -2], // 1: 2x white (player2)
    [-7, -6, -5, -4, -3], // 2
    [-15], // 3
    [], // 4
    [], // 5
    [], // 6: 5x black (player1)
    [], // 7
    [], // 8: 3x black (player1)
    [], // 9
    [], // 10
    [], // 11
    [], // 12: 5x white (player2)
    [], // 13: 5x black (player1)
    [], // 14
    [], // 15
    [], // 16
    [], // 17: 3x white (player2)
    [], // 18
    [1, 2, 3, 4, 5, 6], // 19: 5x white (player2)
    [7], // 20
    [8, 9], // 21
    [], // 22
    [], // 23
    [], // 24: 2x black (player1)
    [11, 12, 10, 13, 14, 15], // 25: 2x black (player1) bar, 0x white (player2) off
  ];

  print(boardToDart(board));

  print(boardToLines(board).join('\n'));

  print('');

  final s = '''
+13-14-15-16-17-18-+-B-+-19-20-21-22-23-24-+-O-+
|                  |   |  O  O  O          | O |
|                  |   |  O     O          | O |
|                  |   |  O                | O |
|                  |   |  O                | O |
|                  |   |  6                | 6 |
|                  |   |                   |   |
|                  |   |              X    | 7 |
|                  |   |              X    | X |
|                  |   |              X    | X |
|                  |   |              X  X | X |
|                  |   |           X  X  X | X |
+12-11-10--9--8--7-+---+--6--5--4--3--2--1-+---+
''';

  print(linesToBoard(s.split('\n').skip(1).toList()));

  // print(boardToDart(linesToBoard(s.split('\n').skip(1).toList()))); // TODO
}

String boardToDart(List<List<int>> board) {
  checkBoard(board);

  String pipLine(int pip) {
    final sb = StringBuffer();
    final p1pieces = board[pip].where((pid) => pid < 0).length;
    final p2pieces = board[pip].where((pid) => pid > 0).length;
    final p1label = p1pieces == 0 ? null : '${p1pieces}x player1';
    final p2label = p2pieces == 0 ? null : '${p2pieces}x player2';
    final labels = [if (p1label != null) p1label, if (p2label != null) p2label];

    sb.write('  [');
    sb.write(board[pip].sorted().map((pid) => pid.toString()).join(', '));
    sb.writeln('], // $pip: ${labels.join(", ")}');

    return sb.toString();
  }

  final sb = StringBuffer();
  sb.writeln('final board = <List<int>>[');

  {
    sb.writeln('');
    sb.writeln('  // player1 off, player2 bar');
    sb.write(pipLine(0));
  }

  sb.writeln('');
  sb.writeln('  // board pips'); // TODO: split this up
  for (var pip = 1; pip != 25; ++pip) {
    sb.write(pipLine(pip));
  }

  {
    sb.writeln('');
    sb.writeln('  // player1 off, player2 bar');
    sb.write(pipLine(25));
  }

  sb.writeln('');
  sb.writeln('];');
  return sb.toString();
}

List<List<int>> linesToBoard(List<String> lines) {
  final board = List<List<int>>.generate(26, (_) => []);

  // TODO

  // checkBoard(board); // TODO
  return board;
}

List<String> boardToLines(List<List<int>> board) {
  checkBoard(board);

  final lines = List<String>.filled(13, null);
  lines[00] = '+13-14-15-16-17-18-+-B-+-19-20-21-22-23-24-+-O-+';
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

  // board pips
  for (var pip = 1; pip != 25; ++pip) {
    final pieces = board[pip].length;
    if (pieces == 0) continue;

    final color = board[pip][0] < 0 ? 'X' : 'O';

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
      assert(false, 'unreachable');
    }
  }

  // player1 off
  {
    final sign = -1;
    final pipPieces = board[0].where((pid) => pid.sign == sign);
    final pieces = pipPieces.length;

    for (var i = 0; i != math.min(pieces, 5); ++i) {
      lines[11 - i] = lines[11 - i].replaceAt(45, 'X');
    }

    if (pieces > 5) {
      final pileup = pieces.toString();
      lines[8 - 1] = lines[8 - 1].replaceAt(45, pileup);
      assert(pileup.length == 1, 'Not handling two-digit pileups');
    }
  }

  // player2 off
  {
    final sign = 1;
    final pipPieces = board[25].where((pid) => pid.sign == sign);
    final pieces = pipPieces.length;

    for (var i = 0; i != math.min(pieces, 5); ++i) {
      lines[i + 1] = lines[i + 1].replaceAt(45, 'O');
    }

    if (pieces > 5) {
      final pileup = pieces.toString();
      lines[4 + 1] = lines[4 + 1].replaceAt(45, pileup);
      assert(pileup.length == 1, 'Not handling two-digit pileups');
    }
  }

  // player1 bar
  {
    final pipPieces = board[25].where((pid) => pid < 0);
    final pieces = pipPieces.length;

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
    final pipPieces = board[0].where((pid) => pid > 0);
    final pieces = pipPieces.length;

    for (var o = 0; o != math.min(pieces, 5); ++o) {
      lines[11 - o] = lines[11 - o].replaceAt(21, 'O');
    }

    if (pieces > 5) {
      final pileup = pieces.toString();
      lines[8 - 1] = lines[8 - 1].replaceAt(21, pileup);
      assert(pileup.length == 1, 'Not handling two-digit pileups');
    }
  }

  return lines;
}

extension on String {
  String replaceAt(int index, String s) => substring(0, index) + s + substring(index + 1);
}

void checkBoard(List<List<int>> board) {
  // track the pieces we find
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

    for (final pieceID in board[pip]) {
      // ensure there aren't any pieces of the wrong color on this pip
      assert(pieceID.sign == board[pip][0].sign);

      // track the pieces we find, looking for dups or missing pieces
      found(pieceID);
    }
  }

  // player1 off
  {
    final sign = -1;
    final pipPieces = board[0].where((pid) => pid.sign == sign);
    final pieces = pipPieces.length;
    for (final pieceID in pipPieces) {
      found(pieceID);
    }

    // if we've got off pieces, ensure there aren't any pieces outside the home board
    if (pieces > 0) {
      for (var pip in List<int>.generate(19, (i) => 25 - i)) {
        assert(board[pip].isEmpty || board[pip][0].sign != sign, 'found X pieces outside home board on pip $pip');
      }
    }
  }

  // player2 off
  {
    final sign = 1;
    final pipPieces = board[25].where((pid) => pid.sign == sign);
    final pieces = pipPieces.length;
    for (final pieceID in pipPieces) {
      found(pieceID);
    }

    // if we've got off pieces, ensure there aren't any pieces outside the home board
    if (pieces > 0) {
      for (var pip in List<int>.generate(19, (i) => 0 + i)) {
        assert(board[pip].isEmpty || board[pip][0].sign != sign, 'found O pieces outside home board on pip $pip');
      }
    }
  }

  // player1 bar
  {
    final pipPieces = board[25].where((pid) => pid < 0);
    for (final pieceID in pipPieces) {
      found(pieceID);
    }
  }

  // player2 bar
  {
    final pipPieces = board[0].where((pid) => pid > 0);
    for (final pieceID in pipPieces) {
      found(pieceID);
    }
  }

  // check that we found all the pieces
  assert(foundPieceIDs.length == 2);
  for (var i = 0; i != 2; ++i) {
    assert(foundPieceIDs[i].length == 15);
    for (var j = 0; j != 15; ++j) {
      final pieceID = i == 0 ? -(j + 1) : j + 1;
      assert(foundPieceIDs[i][j], 'missing pieceID: $pieceID');
    }
  }
}
