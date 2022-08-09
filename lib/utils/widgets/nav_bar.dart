import 'package:flutter/material.dart';
import 'package:shopkeeper/utils/options.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  NavBar({this.title, this.actions});
  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize => new Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(fontSize: 16.0),
      ),
      backgroundColor: primaryColor,
      actions: actions,
    );
  }
}
