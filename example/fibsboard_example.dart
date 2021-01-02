import 'package:fibsboard/fibsboard.dart' as fb;

void main() {
  final lines = fb.linesFromString('''
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

  final board = fb.boardFromLines(lines);
  final lines2 = fb.linesFromBoard(board);
  final board2 = fb.boardFromLines(lines2);

  print(fb.dartFromBoard(board2));
  print('');
  print(lines2.join('\n'));
}
