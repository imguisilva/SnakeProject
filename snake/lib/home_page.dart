import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
import 'package:snake/highscore_tile.dart';
import 'package:snake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomepageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomepageState extends State<HomePage> {
  //Tamanho mapa
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  //score do player
  int currentScore = 0;

  // Posição da cobra
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  // COBRA COMEÇA ANDANDO PRA DIREITA
  var currentDirection = snake_Direction.RIGHT;

  // posição da comida
  int foodPos = 55;

  //Criando a lista de highscore
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocIds();
    super.initState();
  }

  Future getDocIds() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //start Game
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // mantem a cobra andando
        moveSnake();

        // verifica se o jogo acabou
        if (gameOver()) {
          timer.cancel();
          //mostra uma mensagem para o usuario
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Game Over'),
                  content: Column(
                    children: [
                      Text('Seu score é $currentScore'),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'Enter name:'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        NewGame();
                      },
                      color: Colors.pink,
                      child: const Text('Submit'),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    var database = FirebaseFirestore.instance;

    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future NewGame() async {
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    //verificando que a comida nãoe sta embaixo da cobra
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          // parede direita precisa de reajuste
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            //ADD HEAD
            snakePos.add(snakePos.last + 1);
          }
        }

        break;
      case snake_Direction.LEFT:
        {
          // parede direita precisa de reajuste
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            //ADD HEAD
            snakePos.add(snakePos.last - 1);
          }
        }

        break;
      case snake_Direction.UP:
        {
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            //ADD HEAD
            snakePos.add(snakePos.last - rowSize);
          }
        }

        break;
      case snake_Direction.DOWN:
        {
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            //ADD HEAD
            snakePos.add(snakePos.last + rowSize);
          }
        }

        break;
      default:
    }

    //a cobra esta comendo
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      //remove tail
      snakePos.removeAt(0);
    }
  }

  //Game over
  bool gameOver() {
    //o jogo acaba quando a cobra colide com ela mesma
    //tamanha da cobra sem a cabeça
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screemwhith = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screemwhith > 428 ? 428 : screemwhith,
        child: Column(
          children: [
            Expanded(
              //score
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //score atual
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Current Score'),
                        Text(
                          currentScore.toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ],
                    ),
                  ),
                  //maiores scores
                  Expanded(
                    child: gameHasStarted
                        ? Container()
                        : FutureBuilder(
                            future: letsGetDocIds,
                            builder: (context, snapshot) {
                              return ListView.builder(
                                itemCount: highscore_DocIds.length,
                                itemBuilder: (context, index) {
                                  return HighScoreTile(
                                      documentId: highscore_DocIds[index]);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              ),
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: MaterialButton(
                    color: gameHasStarted ? Colors.grey : Colors.pink,
                    onPressed: gameHasStarted ? () {} : startGame,
                    child: const Text('Play'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
