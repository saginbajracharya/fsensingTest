import 'package:flutter/material.dart';

class LableWidget extends StatelessWidget {
  const LableWidget({Key? key,required this.lableText,this.fontSize}) : super(key: key);
  final String lableText;
  final dynamic fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:5.0),
      child: Text(lableText, style: TextStyle(fontSize: fontSize??14, fontWeight: FontWeight.bold)),
    );
  }
}