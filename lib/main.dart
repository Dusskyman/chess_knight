import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Chess());
  }
}

class Chess extends StatefulWidget {
  @override
  _ChessState createState() => _ChessState();
}

class _ChessState extends State<Chess> {
  Timer timer;
  int x;
  int y;
  final String url =
      'https://www.pngkit.com/png/full/627-6276230_chess-horse-png-clipart-chess-piece-knight-chess.png';

  List<String> visitedFields = [];
  var whiteSquareList = [
    ["a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"],
    ["a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7"],
    ["a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6"],
    ["a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5"],
    ["a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4"],
    ["a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3"],
    ["a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2"],
    ["a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"],
  ];
  List<List<int>> horseMove = [
    [1, -2],
    [2, -1],
    [2, 1],
    [1, 2],
    [-1, 2],
    [-2, 1],
    [-2, -1],
    [-1, -2],
  ];

  bool isCorrect(List<int> move, int xx, int yy) {
    if ((xx + move.first < 8 && xx + move.first >= 0) &&
        (yy + move.last < 8 && yy + move.last >= 0) &&
        !(visitedFields.contains(whiteSquareList[xx + move.first]
                [yy + move.last]
            .replaceAll(RegExp('k'), '')))) {
      return true;
    } else {
      return false;
    }
  }

  void startPos() {
    visitedFields.clear();
    x = Random().nextInt(7);
    y = Random().nextInt(7);
    visitedFields.add(whiteSquareList[x][y]);
    whiteSquareList[x][y] = 'k' + whiteSquareList[x][y];
    setState(() {});
    Timer(Duration(seconds: 2), () {
      print('Started from : $visitedFields');
    });
  }

  void move(List<int> move) {
    whiteSquareList[x][y] = whiteSquareList[x][y].replaceAll(RegExp('k'), '');
    x = move.first + x;
    y = move.last + y;
    visitedFields.add(whiteSquareList[x][y]);
    whiteSquareList[x][y] = 'k' + whiteSquareList[x][y];
    setState(() {});
    // visitedFields.sort();
    print('Visited: $visitedFields');
  }

  void choseBestMove(List<List<int>> list) {
    int phantomX = 0;
    int phantomY = 0;
    int minOfturns = 8;
    List<int> goodTurn = [0, 0];
    for (var i = 0; i < list.length; i++) {
      int numOfturns = 0;
      phantomX = list[i].first + x;
      phantomY = list[i].last + y;
      // print('[$phantomX][$phantomY]');
      for (var j = 0; j < horseMove.length; j++) {
        if (isCorrect(horseMove[j], phantomX, phantomY)) {
          numOfturns++;
        }
        if (j == horseMove.length - 1) {
          if (minOfturns > numOfturns && numOfturns > 0) {
            minOfturns = numOfturns;
            goodTurn = list[i];
          } else if (list.length == 1) {
            goodTurn = list.first;
          }
        }
      }
    }
    minOfturns = 8;
    if (goodTurn.first == 0) {
      print('FUCK... gg. Cleared fields: ${visitedFields.length}');
      timer.cancel();
    }
    print(
        'The turn:$goodTurn \nFuture Position: ${whiteSquareList[x + goodTurn.first][y + goodTurn.last]}');
    move(goodTurn);
  }

  void checkMove() {
    timer = Timer.periodic(
      Duration(milliseconds: 500),
      (timer) {
        List<List<int>> correctMoves = [];
        var i = 0;
        do {
          i++;
          if (isCorrect(horseMove[i - 1], x, y)) {
            correctMoves.add(horseMove[i - 1]);
          }
          if (i == horseMove.length && visitedFields.length != 63) {
            print(
                '_____________________ \nList of Correct Moves: $correctMoves');
            Timer(
                Duration(microseconds: 250), () => choseBestMove(correctMoves));
          } else if (visitedFields.length == 63 && correctMoves.length != 0) {
            move(correctMoves.first);
          }
          if (visitedFields.length == 64) {
            var sorted = visitedFields;
            // sorted.sort();
            print('GG. You win');
            print('$sorted \n Вы прошли все ${visitedFields.length} поля!');
            timer.cancel();
          }
        } while (i < horseMove.length);
      },
    );
  }

  Color fieldColor(String e) {
    if (int.parse(e.characters.last) % 2 == 0 &&
        e.contains(new RegExp(r'[b, d, f, h]'))) {
      return Colors.black;
    }
    if (int.parse(e.characters.last) % 2 == 1 &&
        e.contains(new RegExp(r'[a, c, e, g]'))) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  void initState() {
    startPos();
    Timer(Duration(seconds: 2), () => checkMove());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.alarm_add_outlined),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) => Chess()));
          },
        ),
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          width: 330,
          height: 330,
          color: Colors.brown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: whiteSquareList
                .map(
                  (en) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: en
                        .map(
                          (e) => Container(
                            width: 40,
                            height: 40,
                            color: fieldColor(e),
                            child: e.contains('k')
                                ? Image.asset('assets/images/kc.png')
                                : Center(
                                    child: visitedFields.indexOf(e) != -1
                                        ? Text(
                                            '${visitedFields.indexOf(e)}',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 30),
                                          )
                                        : null),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
