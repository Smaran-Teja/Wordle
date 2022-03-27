class WordleBlock {
  String correctLetter;
  int letterPosition;
  String? currentLetter;
  String? currentStatus;
  WordleBlock(
      {required this.correctLetter,
      required this.letterPosition,
      required this.currentLetter,
      required this.currentStatus});
}

/*
// ignore: use_key_in_widget_constructors
class WordleBlock extends StatefulWidget {
  String correctLetter;
  int letterPosition;
  String? currentLetter;

  // ignore: use_key_in_widget_constructors
  WordleBlock(
      {required this.correctLetter,
      required this.letterPosition,
      required this.currentLetter});

  @override
  State<WordleBlock> createState() => _WordleBlockState();
}

class _WordleBlockState extends State<WordleBlock> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String curLetter;
    if (widget.currentLetter == null) {
      curLetter = "";
    } else {
      curLetter = widget.currentLetter!;
    }

    // ignore: sized_box_for_whitespace
    return Container(
      child: Center(
          child: Text(
        curLetter,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      )),
      height: height * 0.07,
      width: width * 0.15,
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xff808080),
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }
}
*/