import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MainDialog extends StatefulWidget {
  final String title;
  final List<String> itemsName;
  List<bool> itemsSelected;

  MainDialog(this.title, this.itemsName, this.itemsSelected);

  @override
  _MainDialogState createState() =>
      _MainDialogState(this.title, this.itemsName, this.itemsSelected);
}

class _MainDialogState extends State<MainDialog> {
  final String title;
  final List<String> itemsName;
  List<bool> itemsSelected;

  _MainDialogState(this.title, this.itemsName, this.itemsSelected);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: List.generate(
        itemsName.length,
        (index) => CheckboxListTile(
          title: Text(itemsName[index]),
          value: itemsSelected[index],
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          onChanged: (bool value) {
            setState(() {
              itemsSelected[index] = value;
            });
          },
        ),
      ),
      title: Text(title),
    );
  }
}
