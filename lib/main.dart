import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animations/animations.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('URLBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List urls = [];

  String _title;
  String _url;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    var box = Hive.box('URLBox');
    urls = box.get("urls") != null ? box.get("urls") : [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("URL launcher"),
      ),
      floatingActionButton: OpenContainer(
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
          return Scaffold(
              appBar: AppBar(
                title: Text("Add new url"),
              ),
              body: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (value) => _title = value,
                      decoration: InputDecoration(labelText: "Enter title"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onSaved: (value) => _url = value,
                      decoration: InputDecoration(labelText: "Enter url"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter url';
                        }
                        return null;
                      },
                    ),
                    DayItem(1),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();

                          urls.add({"title": _title, "url": _url});

                          var box = Hive.box("URLBox");
                          box.put("urls", urls);
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ));
        },
      ),
      body: ListView.separated(
        itemCount: urls.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            child: SlideAnimation(
              child: FadeInAnimation(
                child: Card(
                  elevation: 10,
                  child: Slidable(
                    actionPane: SlidableStrechActionPane(),
                    secondaryActions: [
                      IconSlideAction(
                        caption: "Edit",
                        color: Colors.blue,
                        icon: Icons.edit,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text("Edit url"),
                                ),
                                body: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        onSaved: (value) => _title = value,
                                        initialValue: index != null
                                            ? urls[index]["title"]
                                            : null,
                                        decoration: InputDecoration(
                                            labelText: "Enter title"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter title';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        onSaved: (value) => _url = value,
                                        initialValue: index != null
                                            ? urls[index]["url"]
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: "Enter url",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter url';
                                          }
                                          return null;
                                        },
                                      ),
                                      DayItem(1),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            _formKey.currentState.save();
                                            urls[index]["title"] = _title;
                                            urls[index]["url"] = _url;

                                            var box = Hive.box("URLBox");
                                            box.put("urls", urls);
                                            Navigator.pop(context);
                                            setState(() {});
                                          }
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () async => await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm'),
                              content: Text(
                                "Are you sure deleting ${urls[index]['title']} item?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      urls.removeAt(index);
                                      var box = Hive.box("URLBox");
                                      box.put("urls", urls);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    child: ListTile(
                      title: Text(urls[index]["title"]),
                      trailing: Icon(Icons.chevron_left),
                      onTap: () async {
                        try {
                          await launch(urls[index]["url"]);
                        } catch (e) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                    "Could not launch ${urls[index]['url']}"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DayItem extends StatefulWidget {
  int index;

  DayItem(int index);

  @override
  _DayItemState createState() => _DayItemState(index);
}

class _DayItemState extends State<DayItem> {
  _DayItemState(index);
  int index;
  final List<String> daysName = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  List<bool> _daysActive = List.generate(7, (index) => true);

  @override
  Widget build(BuildContext context) {
    print(index);
    print(widget.index);
    return CheckboxListTile(
      value: _daysActive[0],
      title: Text(daysName[0]),
      onChanged: (bool newVaule) {
        setState(() {
          _daysActive[0] = newVaule;
        });
      },
    );
  }
}
