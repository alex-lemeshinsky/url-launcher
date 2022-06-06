import 'package:URL_launcher/models/item.dart';
import 'package:URL_launcher/providers/db_provider.dart';
import 'package:URL_launcher/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox('URLBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DbProvider>(create: (_) => DbProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'URL launcher',
        home: HomeScreen(),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            secondary: Colors.blue,
            primary: Colors.blue,
          ),
        ),
      ),
    );
  }
}
