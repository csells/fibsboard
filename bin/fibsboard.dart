import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'package:dartx/dartx.dart';

void main() {
  final lines = _linesFromString('''
+13-14-15-16-17-18-+BAR+19-20-21-22-23-24-+OFF+
|             O  O | O |    O  O        O |   |
|             O    |   |       O        O |   |
|             O    |   |                O |   |
|             O    |   |                O |   |
|             O    |   |                O |   |
|                  |   |                  |   |
|                  |   | 9                | 6 |
|                  |   | X                | X |
|                  |   | X                | X |
|                  |   | X                | X |
|                  |   | X                | X |
+12-11-10--9--8--7-+---+-6--5--4--3--2--1-+---+
''');

  final board = linesToBoard(lines);
  final lines2 = boardToLines(board);

  assert(lines2.length == lines.length);
  for (var i = 0; i != 13; ++i) {
    assert(lines[i] == lines2[i]);
  }

  final board2 = linesToBoard(lines2);
  assert(board2.length == board.length);
  for (var i = 0; i != 26; ++i) {
    assert(board2[i].length == board[i].length);
    for (var j = 0; j != board[i].length; ++j) {
      assert(board[i][j] == board2[i][j]);
    }
  }

  print(boardToDart(board2));
  print('');
  print(lines2.join('\n'));
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
  sb.writeln('  // player1 home board');
  for (var pip = 1; pip != 7; ++pip) {
    sb.write(pipLine(pip));
  }

  sb.writeln('');
  sb.writeln('  // player1 outer board');
  for (var pip = 7; pip != 13; ++pip) {
    sb.write(pipLine(pip));
  }

  sb.writeln('');
  sb.writeln('  // player2 outer board');
  for (var pip = 13; pip != 19; ++pip) {
    sb.write(pipLine(pip));
  }

  sb.writeln('');
  sb.writeln('  // player2 home board');
  for (var pip = 19; pip != 25; ++pip) {
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
  checkLines(lines);
  final board = List<List<int>>.generate(26, (_) => []);
  final pieceCounts = <String, int>{'X': 0, 'O': 0};
  void totalPieceCount(int pip, Map<String, int> pieceCount) {
    if (pieceCount.isEmpty) return;
    assert(pieceCount.length == 1);

    final color = pieceCount.keys.single;
    final pieces = pieceCount[color];
    for (var i = 0; i != pieces; ++i) {
      final pid = color == 'X' ? -(pieceCounts[color] + i + 1) : pieceCounts[color] + i + 1;
      board[pip].add(pid);
    }

    pieceCounts[color] += pieces;
  }

  // board pips
  for (var pip = 1; pip != 25; ++pip) {
    if (pip >= 1 && pip <= 6) {
      // player1 home board
      totalPieceCount(pip, _readLineUp(lines: lines, dx: 40 - (pip - 1) * 3, dy: 11));
    } else if (pip >= 7 && pip <= 12) {
      // player1 outer board
      totalPieceCount(pip, _readLineUp(lines: lines, dx: 17 - (pip - 7) * 3, dy: 11));
    } else if (pip >= 13 && pip <= 18) {
      // player2 outer board
      totalPieceCount(pip, _readLineDown(lines: lines, dx: 2 + (pip - 13) * 3, dy: 1));
    } else if (pip >= 19 && pip <= 24) {
      // player2 home board
      totalPieceCount(pip, _readLineDown(lines: lines, dx: 25 + (pip - 19) * 3, dy: 1));
    } else {
      assert(false, 'unreachable');
    }
  }

  // player1 and player2 off
  totalPieceCount(0, _readLineUp(lines: lines, dx: 44, dy: 11));
  totalPieceCount(25, _readLineDown(lines: lines, dx: 44, dy: 1));

  // player1 and player2 bar
  totalPieceCount(25, _readLineUp(lines: lines, dx: 21, dy: 11));
  totalPieceCount(0, _readLineDown(lines: lines, dx: 21, dy: 1));

  checkBoard(board);
  return board;
}

bool _isDigit(String char) => (char.codeUnitAt(0) ^ 0x30) <= 9;

Map<String, int> _readLineVert({
  @required List<String> lines,
  @required int dx,
  @required int dy,
  @required int dir,
}) {
  assert(lines != null);
  assert(lines.length == 13);
  assert(dx != null);
  assert(dx >= 0 && dx <= 47);
  assert(dy != null);
  assert(dy >= 0 && dy <= 12);
  assert(dir == 1 || dir == -1);

  final pieceCount = <String, int>{};
  String oldChar;

  for (var i = 0; i != 5; ++i) {
    final char = lines[dy + i * dir][dx];
    if (char == ' ') break;
    assert(oldChar == null || oldChar == char || _isDigit(char));

    if (char == 'X' || char == 'O') {
      assert(!pieceCount.containsKey(char == 'X' ? 'O' : 'X'));
      pieceCount[char] = (pieceCount[char] ?? 0) + 1;
    } else if (_isDigit(char)) {
      assert(i == 4);
      if (oldChar == 'X' || oldChar == 'O') {
        assert(!pieceCount.containsKey(oldChar == 'X' ? 'O' : 'X'));
        final pieces = int.parse(char);
        assert(pieces >= 6 && pieces <= 9);
        pieceCount[oldChar] = pieces;
      } else {
        assert(false);
      }
    } else {
      assert(false);
    }

    oldChar = char;
  }

  assert(pieceCount.isEmpty || pieceCount.length == 1);
  return pieceCount;
}

Map<String, int> _readLineUp({
  @required List<String> lines,
  @required int dx,
  @required int dy,
}) =>
    _readLineVert(lines: lines, dx: dx, dy: dy, dir: -1);

Map<String, int> _readLineDown({
  @required List<String> lines,
  @required int dx,
  @required int dy,
}) =>
    _readLineVert(lines: lines, dx: dx, dy: dy, dir: 1);

void _writeLineVert({
  @required List<String> lines,
  @required int dx,
  @required int dy,
  @required String char,
  @required int length,
  @required int dir,
}) {
  assert(lines != null);
  assert(lines.length == 13);
  assert(dx != null);
  assert(dx >= 0 && dx <= 47);
  assert(dy != null);
  assert(dy >= 0 && dy <= 12);
  assert(char != null);
  assert(char.length == 1);
  assert(dir == 1 || dir == -1);

  for (var i = 0; i != math.min(length, 5); ++i) {
    lines[dy + i * dir] = lines[dy + i * dir].replaceAt(dx, char);
  }

  if (length > 5) {
    final pileup = length.toString();
    assert(pileup.length == 1, 'Not handling two-digit pileups');
    lines[dy + 4 * dir] = lines[dy + 4 * dir].replaceAt(dx, pileup);
  }
}

void _writeLineUp({
  @required List<String> lines,
  @required int dx,
  @required int dy,
  @required String char,
  @required int length,
}) =>
    _writeLineVert(lines: lines, dx: dx, dy: dy, char: char, length: length, dir: -1);

void _writeLineDown({
  @required List<String> lines,
  @required int dx,
  @required int dy,
  @required String char,
  @required int length,
}) =>
    _writeLineVert(lines: lines, dx: dx, dy: dy, char: char, length: length, dir: 1);

// everything is a constant except the dots when can be replaced
const _boardTemplate = '''
+13-14-15-16-17-18-+BAR+19-20-21-22-23-24-+OFF+
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
|                  |   |                  |   |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
| .  .  .  .  .  . | . | .  .  .  .  .  . | . |
+12-11-10--9--8--7-+---+-6--5--4--3--2--1-+---+
''';

List<String> _linesFromString(String s) => s.split('\n').take(13).toList();
List<String> _linesFromTemplate() => _linesFromString(_boardTemplate.replaceAll('.', ' '));

List<String> boardToLines(List<List<int>> board) {
  checkBoard(board);
  final lines = _linesFromTemplate();

  // board pips
  for (var pip = 1; pip != 25; ++pip) {
    final pieces = board[pip].length;
    if (pieces == 0) continue;

    final color = board[pip][0] < 0 ? 'X' : 'O';

    if (pip >= 1 && pip <= 6) {
      // player1 home board
      _writeLineUp(lines: lines, dx: 40 - (pip - 1) * 3, dy: 11, char: color, length: pieces);
    } else if (pip >= 7 && pip <= 12) {
      // player1 outer board
      _writeLineUp(lines: lines, dx: 17 - (pip - 7) * 3, dy: 11, char: color, length: pieces);
    } else if (pip >= 13 && pip <= 18) {
      // player2 outer board
      _writeLineDown(lines: lines, dx: 2 + (pip - 13) * 3, dy: 1, char: color, length: pieces);
    } else if (pip >= 19 && pip <= 24) {
      // player2 home board
      _writeLineDown(lines: lines, dx: 25 + (pip - 19) * 3, dy: 1, char: color, length: pieces);
    } else {
      assert(false, 'unreachable');
    }
  }

  // player1 and player2 off
  _writeLineUp(lines: lines, dx: 44, dy: 11, char: 'X', length: board[0].where((pid) => pid < 0).length);
  _writeLineDown(lines: lines, dx: 44, dy: 1, char: 'O', length: board[25].where((pid) => pid > 0).length);

  // player1 and player2 bar
  _writeLineUp(lines: lines, dx: 21, dy: 11, char: 'X', length: board[25].where((pid) => pid < 0).length);
  _writeLineDown(lines: lines, dx: 21, dy: 1, char: 'O', length: board[0].where((pid) => pid > 0).length);

  checkLines(lines);
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

void checkLines(List<String> lines) {
  final tlines = _boardTemplate.split('\n').take(13).toList();
  assert(lines.length == 13);
  assert(tlines.length == 13);
  for (var i = 0; i != lines.length; ++i) {
    assert(lines[i].length == tlines[i].length);
    for (var j = 0; j != lines[i].length; ++j) {
      assert(tlines[i][j] == '.' || tlines[i][j] == lines[i][j]);
    }
  }
}
