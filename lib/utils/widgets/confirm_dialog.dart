import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class ConfirmDialog extends StatelessWidget {
  ConfirmDialog({this.title, this.content, this.actions});
  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Text(title, style: TextStyle(fontSize: 15.0),),
      content: content,
      actions: actions,
      contentTextStyle: TextStyle(fontSize: 13.0, color: Colors.black, fontFamily: 'Raleway'),
    );
  }
}