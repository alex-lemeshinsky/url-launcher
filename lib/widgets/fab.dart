import 'package:URL_launcher/screens/edit_item_screen.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      closedShape: CircleBorder(),
      closedBuilder: (context, action) {
        return FloatingActionButton(
          elevation: 0,
          child: Icon(Icons.add),
          onPressed: action,
        );
      },
      openBuilder: (context, action) {
        return EditItemScreen();
      },
    );
  }
}
