import 'package:URL_launcher/models/item.dart';
import 'package:URL_launcher/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditItemScreen extends StatelessWidget {
  EditItemScreen({
    Key? key,
    this.index,
    this.title,
    this.url,
  }) : super(key: key);

  int? index; // used as key in hive db
  String? title;
  String? url;

  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _urlFocusNode = FocusNode();

  VoidCallback submitForm = () {};

  @override
  Widget build(BuildContext context) {
    DbProvider dbProvider = Provider.of<DbProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(title == null ? "Add new url" : "Edit url")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                initialValue: title,
                focusNode: _titleFocusNode,
                onSaved: (value) => title = value,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: "Enter title"),
                onEditingComplete: () => _urlFocusNode.requestFocus(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter title';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: url ?? "https://",
                focusNode: _urlFocusNode,
                onSaved: (value) =>
                    url = value!.replaceAll("https://https://", "https://"),
                decoration: InputDecoration(labelText: "Enter url"),
                validator: (value) {
                  //regexp to check url
                  final regexp = RegExp(
                      "(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})");

                  if (value == null || value.isEmpty) {
                    return 'Enter url';
                  } else if (!regexp.hasMatch(value)) {
                    return "Enter link in correct way 'https://example.com'";
                  }

                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    dbProvider.addOrUpdateItem(
                      item: Item(title: title!, url: url!),
                      index: index,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
