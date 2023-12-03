import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'models/colorseed_list.dart';
import 'models/expense.dart';
import 'widgets/expenses/expenses_scr.dart';

var expenseBox = Hive.box<Expense>('expenses_box');
var colorsBox = Hive.box<ColorSeed>('colors_box');
var brightnessBox = Hive.box('set_brightness');

void main() async {
  var path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter(ExpenseAdapter())
    ..registerAdapter(CategoryAdapter())
    ..registerAdapter(ColorSeedAdapter());

  await Hive.initFlutter();
  await Hive.openBox<Expense>('expenses_box');
  await Hive.openBox<ColorSeed>('colors_box');
  await Hive.openBox('set_brightness');

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  void dispose() {
    expenseBox.close();
    colorsBox.close();
    brightnessBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: colorsBox.listenable(),
      builder: (context, box, _) {
        final onColorSelected =
            box.get('color', defaultValue: ColorSeed.values[0]);
        ColorSeed colorSelected = onColorSelected!;

        final kColorScheme = ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: colorSelected.color,
        );
        final kDarkColorScheme = ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: colorSelected.color,
        );

        return ValueListenableBuilder(
            valueListenable: brightnessBox.listenable(),
            builder: (context, box, _) {
              final isBright = box.get('isBright', defaultValue: false);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ru-RU'),
                ],
                themeMode: isBright ? ThemeMode.light : ThemeMode.dark,
                theme: ThemeData(
                  useMaterial3: false,
                  colorScheme: isBright ? kColorScheme : kDarkColorScheme,
                  appBarTheme: const AppBarTheme().copyWith(
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: isBright
                          ? kColorScheme.surfaceVariant
                          : const Color.fromARGB(255, 23, 23, 23),
                      statusBarIconBrightness:
                          isBright ? Brightness.dark : Brightness.light,
                    ),
                    toolbarTextStyle: TextStyle(
                      fontFamily: 'Pangolin',
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                    ),
                    centerTitle: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: isBright
                        ? kColorScheme.primary
                        : kDarkColorScheme.primary,
                  ),
                  scaffoldBackgroundColor: isBright
                      ? kColorScheme.surfaceVariant
                      : const Color.fromARGB(255, 23, 23, 23),
                  textTheme: ThemeData().textTheme.copyWith(
                        headlineMedium: TextStyle(
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                        ),
                        titleLarge: TextStyle(
                          fontFamily: 'Pangolin',
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                          fontSize: 24,
                        ),
                        titleMedium: TextStyle(
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                        ),
                        bodyLarge: TextStyle(
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                        ),
                        bodyMedium: TextStyle(
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                        ),
                        bodySmall: TextStyle(
                          color: isBright
                              ? kColorScheme.primary
                              : kDarkColorScheme.primary,
                        ),
                      ),
                  floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: isBright
                        ? kColorScheme.inversePrimary
                        : kDarkColorScheme.inversePrimary.withOpacity(0.85),
                    foregroundColor: isBright
                        ? kColorScheme.primary
                        : kDarkColorScheme.primary,
                  ),
                  bottomAppBarTheme: BottomAppBarTheme(
                    shape: const CircularNotchedRectangle(),
                    color: isBright
                        ? kColorScheme.inversePrimary
                        : kDarkColorScheme.inversePrimary.withOpacity(0.7),
                    height: 60,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: isBright
                          ? kColorScheme.primary
                          : kDarkColorScheme.primary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(
                        color: isBright
                            ? kColorScheme.primary
                            : kDarkColorScheme.primary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isBright
                            ? kColorScheme.primary.withOpacity(0.5)
                            : kDarkColorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                home: const Expenses(),
              );
            });
      });
}
