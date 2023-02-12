import 'package:flutter/material.dart';

class TitleWidgets extends StatelessWidget {
  const TitleWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Routines',
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.orange, fontSize: 80, fontWeight: FontWeight.w300),
    );
  }
}
