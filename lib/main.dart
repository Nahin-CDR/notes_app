import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:notes/home.dart';
import 'package:notes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('shopping_box');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProviderView themeProviderView = ThemeProviderView();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => themeProviderView,
        child: Consumer<ThemeProviderView>(
          builder: (context, value, _) {
            return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: value.themeMode,
                home: const HomeScreen()
            );
          },
        )
    );
  }
}
