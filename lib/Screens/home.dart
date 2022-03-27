import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/Constants/words.dart';
import 'package:wordle/Models/keyboard_letter.dart';
import 'package:wordle/Models/wordle_block.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var correctWord = answers[Random().nextInt(2314)].toUpperCase();
  int? currentCol = -1;
  int currentRow = 0;
  String alphabet = "QWERTYUIOPASDFGHJKLZXCVBNM";
  SnackBar snackBar = const SnackBar(
    content: Text('Word not found, try again.'),
  );
  // ignore: avoid_init_to_null
  List<List>? wordleArray = null;

  ///Single WordleBlock row generator
  List wordleRowList() {
    List wordleRow = List.filled(5, null);
    for (int i = 0; i < 5; i++) {
      wordleRow[i] = WordleBlock(
          correctLetter: correctWord.substring(i, i + 1),
          letterPosition: (i + 1),
          currentLetter: null,
          currentStatus: null);
    }
    return wordleRow;
  }

  ///Update letter in WordleBlock from keyboard letter onpressed
  void updateArray(String letter) {
    setState(() {
      if (currentCol != null) {
        wordleArray![currentRow][currentCol! + 1].currentLetter = letter;
        if (currentCol! <= 3) {
          currentCol = currentCol! + 1;
        }
      }
    });
  }

  ///function to check if an entered word is valid
  bool isValidWord() {
    String? l1 = wordleArray![currentRow][0].currentLetter;
    String? l2 = wordleArray![currentRow][1].currentLetter;
    String? l3 = wordleArray![currentRow][2].currentLetter;
    String? l4 = wordleArray![currentRow][3].currentLetter;
    String? l5 = wordleArray![currentRow][4].currentLetter;

    String? word = (l1! + l2! + l3! + l4! + l5!).toLowerCase();

    if (allowedGuesses.contains(word)) {
      return true;
    } else {
      return false;
    }
  }

  ///KeyboardLetter currentState(color) changing function
  void setKeyboardLetterColor(String letter, String state) {
    //Creating a map of all letters of alphabets and corresponding KeyboardLetter objects
    Map keyMap = {};
    for (int i = 0; i <= 25; i++) {
      if (i <= 9) {
        keyMap[alphabet.substring(i, i + 1)] = keyRow1![i];
      } else if (i <= 18) {
        keyMap[alphabet.substring(i, i + 1)] = keyRow2![i - 10];
      } else if (i <= 25) {
        keyMap[alphabet.substring(i, i + 1)] = keyRow3![i - 19];
      }
    }

    if (keyMap[letter].currentState != "Green") {
      setState(() {
        keyMap[letter].currentState = state;
      });
    }
  }

  ///Enter button onpressed function
  void onEnter() async {
    bool flag = true; // if true then guess (word) is correct
    if (currentCol == 4 && isValidWord()) {
      setState(() {
        currentCol = null;
      });
      for (int i = 0; i <= 4; i++) {
        WordleBlock wordleBlock = wordleArray![currentRow][i];
        await Future.delayed(const Duration(
            milliseconds:
                300)); //delay for checking each letter for dramatic effect
        setState(() {
          //Green condition
          if (wordleBlock.currentLetter! == correctWord.substring(i, i + 1)) {
            wordleBlock.currentStatus = "Green";
            setKeyboardLetterColor(wordleBlock.currentLetter!, "Green");
          } else {
            flag =
                false; //atleast one of the letters != green so word cannot be correct
            //Yellow condition
            for (int j = 0; j <= 4; j++) {
              if (wordleBlock.currentLetter! ==
                  correctWord.substring(j, j + 1)) {
                wordleBlock.currentStatus = "Yellow";
                setKeyboardLetterColor(wordleBlock.currentLetter!, "Yellow");
              }
            }
            //Grey condition (not yellow or green = grey)
            if (wordleBlock.currentStatus != "Yellow") {
              wordleBlock.currentStatus = "Grey";
              setKeyboardLetterColor(wordleBlock.currentLetter!, "Grey");
            }
          }
        });
      }

      if (flag == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("You won!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      reset();
                    });
                  },
                  child: const Text("Play again",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black)),
                ),
              )
            ],
          ),
        );
      } else if (currentRow == 5 && flag != true) {
        await Future.delayed(const Duration(milliseconds: 300));
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("You lost!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text("The word was: " + correctWord,
                textAlign: TextAlign.center),
            actions: <Widget>[
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      reset();
                    });
                  },
                  child: const Text("Play again",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black)),
                ),
              )
            ],
          ),
        );
      } else {
        setState(() {
          currentCol = -1;
          currentRow++;
        });
      }
    } else if (currentCol == 4 && isValidWord() == false) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///1 second delay function for initState
  void await() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  List? keyRow1;
  List? keyRow2;
  List? keyRow3;

  /// Reset function (called after end of a game)
  void reset() {
    //wordleArray initialization
    wordleArray = List.generate(6, (i) => wordleRowList());

    //Keyboard letters and initialization
    keyRow1 = List.generate(
        10,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i, i + 1),
              currentState: null,
              updateFunc: updateArray,
            )); // 0 to 9
    keyRow2 = List.generate(
        9,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i + 10, i + 11),
              currentState: null,
              updateFunc: updateArray,
            )); // 9 to 18
    keyRow3 = List.generate(
        7,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i + 19, i + 20),
              currentState: null,
              updateFunc: updateArray,
            )); // 18 to 25
    currentCol = -1;
    currentRow = 0;
    correctWord = answers[Random().nextInt(2314)].toUpperCase();
  }

  @override

  ///Initializer function to initialize keyboardLetters (keyrows) and wordleArray
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await();
    //wordleArray initilization
    wordleArray = List.generate(6, (i) => wordleRowList());

    //Keyboard letters and initialisation
    keyRow1 = List.generate(
        10,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i, i + 1),
              currentState: null,
              updateFunc: updateArray,
            )); // 0 to 9
    keyRow2 = List.generate(
        9,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i + 10, i + 11),
              currentState: null,
              updateFunc: updateArray,
            )); // 9 to 18
    keyRow3 = List.generate(
        7,
        (i) => KeyboardLetter(
              letter: alphabet.substring(i + 19, i + 20),
              currentState: null,
              updateFunc: updateArray,
            )); // 18 to 25
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    ///WordleBlock container UI
    Container wbContainer(WordleBlock wb) {
      Color borderColor;
      Color textColor;
      if (wb.currentStatus == "Green") {
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (wb.currentStatus == "Yellow") {
        borderColor = Colors.yellow;
        textColor = Colors.yellow;
      } else if (wb.currentStatus == "Grey") {
        borderColor = Colors.black;
        textColor = Colors.black;
      } else {
        borderColor = Colors.grey[600]!;
        textColor = Colors.black;
      }
      String curLetter;
      if (wb.currentLetter == null) {
        curLetter = "";
      } else {
        curLetter = wb.currentLetter!;
      }
      return Container(
        child: Center(
            child: Text(
          curLetter,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: textColor),
        )),
        height: height * 0.07,
        width: width * 0.15,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            color: Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(2))),
      );
    }

    ///KeyboardLetter container UI
    Container keyboardLetterContainer(KeyboardLetter kl) {
      Color color;
      if (kl.currentState == "Green") {
        color = Colors.green;
      } else if (kl.currentState == "Yellow") {
        color = Colors.yellow;
      } else if (kl.currentState == "Grey") {
        color = Colors.grey[600]!;
      } else {
        color = Colors.grey[300]!;
      }
      return Container(
        child: MaterialButton(
          child: Text(
            kl.letter,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            updateArray(kl.letter);
          },
        ),
        height: height * 0.08,
        width: width * 0.09,
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(7))),
      );
    }

    ///Back Button
    Container backKey = Container(
      child: MaterialButton(
        child: const Center(child: Icon(Icons.backspace)),
        onPressed: () {
          setState(() {
            if (currentCol! >= 0) {
              wordleArray![currentRow][currentCol!].currentLetter = "";
              currentCol = currentCol! - 1;
            }
          });
        },
      ),
      height: height * 0.08,
      width: width * 0.15,
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(7))),
    );

    ///Enter Button
    Container enterKey = Container(
      child: MaterialButton(
          child: const Center(child: Icon(Icons.arrow_forward)),
          onPressed: () async => onEnter()),
      height: height * 0.08,
      width: width * 0.15,
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(7))),
    );

    ///Scaffold
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Wordle"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![0][0]),
              wbContainer(wordleArray![0][1]),
              wbContainer(wordleArray![0][2]),
              wbContainer(wordleArray![0][3]),
              wbContainer(wordleArray![0][4]),
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![1][0]),
              wbContainer(wordleArray![1][1]),
              wbContainer(wordleArray![1][2]),
              wbContainer(wordleArray![1][3]),
              wbContainer(wordleArray![1][4])
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![2][0]),
              wbContainer(wordleArray![2][1]),
              wbContainer(wordleArray![2][2]),
              wbContainer(wordleArray![2][3]),
              wbContainer(wordleArray![2][4]),
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![3][0]),
              wbContainer(wordleArray![3][1]),
              wbContainer(wordleArray![3][2]),
              wbContainer(wordleArray![3][3]),
              wbContainer(wordleArray![3][4])
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![4][0]),
              wbContainer(wordleArray![4][1]),
              wbContainer(wordleArray![4][2]),
              wbContainer(wordleArray![4][3]),
              wbContainer(wordleArray![4][4])
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              wbContainer(wordleArray![5][0]),
              wbContainer(wordleArray![5][1]),
              wbContainer(wordleArray![5][2]),
              wbContainer(wordleArray![5][3]),
              wbContainer(wordleArray![5][4])
            ],
          ),
          SizedBox(height: height * 0.07), //0.07
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              keyboardLetterContainer(keyRow1![0]),
              keyboardLetterContainer(keyRow1![1]),
              keyboardLetterContainer(keyRow1![2]),
              keyboardLetterContainer(keyRow1![3]),
              keyboardLetterContainer(keyRow1![4]),
              keyboardLetterContainer(keyRow1![5]),
              keyboardLetterContainer(keyRow1![6]),
              keyboardLetterContainer(keyRow1![7]),
              keyboardLetterContainer(keyRow1![8]),
              keyboardLetterContainer(keyRow1![9]),
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: width * 0.04),
              keyboardLetterContainer(keyRow2![0]),
              keyboardLetterContainer(keyRow2![1]),
              keyboardLetterContainer(keyRow2![2]),
              keyboardLetterContainer(keyRow2![3]),
              keyboardLetterContainer(keyRow2![4]),
              keyboardLetterContainer(keyRow2![5]),
              keyboardLetterContainer(keyRow2![6]),
              keyboardLetterContainer(keyRow2![7]),
              keyboardLetterContainer(keyRow2![8]),
              SizedBox(width: width * 0.04),
            ],
          ),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              backKey,
              keyboardLetterContainer(keyRow3![0]),
              keyboardLetterContainer(keyRow3![1]),
              keyboardLetterContainer(keyRow3![2]),
              keyboardLetterContainer(keyRow3![3]),
              keyboardLetterContainer(keyRow3![4]),
              keyboardLetterContainer(keyRow3![5]),
              keyboardLetterContainer(keyRow3![6]),
              enterKey
            ],
          )
        ],
      ),
    );
  }
}
