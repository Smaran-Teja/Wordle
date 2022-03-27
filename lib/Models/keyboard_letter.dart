import 'package:flutter/material.dart';

// ignore: must_be_immutable
class KeyboardLetter {
  String letter;
  String? currentState;
  final ValueChanged<String> updateFunc;
  // ignore: use_key_in_widget_constructors
  KeyboardLetter(
      {required this.letter,
      required this.currentState,
      required this.updateFunc});
}
