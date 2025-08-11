import 'package:flutter/material.dart';

AppBar buildCommonAppBar({
  required String title,
  List<Widget>? actions,
  bool showBackButton = true,
}) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.blue[600],
    foregroundColor: Colors.white,
    elevation: 2,
    automaticallyImplyLeading: showBackButton,
    actions: actions,
  );
}
