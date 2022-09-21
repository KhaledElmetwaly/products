import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:task/cubit/cubit.dart';
import 'package:task/cubit/states.dart';
import 'package:task/modules/manage_products.dart';
import 'package:task/network/cashe_helper.dart';
import 'package:task/network/dio_helper.dart';
import 'cubit/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await DioHelper.init();
  await CasheHelper.init();

  // bool? isDark = CasheHelper.getBoolean(key: "isDark");
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var brightness = SchedulerBinding.instance.window.platformBrightness;
  late StreamSubscription subscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
    });
    bool isDarkMode = brightness == Brightness.dark;
    CasheHelper.putBoolean(key: "isDark", value: isDarkMode);
  }

//
  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCubit>(
      create: (context) => TaskCubit()
        ..initConnectionChecker()
        ..changeModes()
        ..createDatabase()
        ..getHome(),
      child: BlocConsumer<TaskCubit, TaskStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: const TextTheme(
                bodyText1: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              scaffoldBackgroundColor: Colors.grey[200],
              appBarTheme: AppBarTheme(
                iconTheme: const IconThemeData(color: Colors.black),
                systemOverlayStyle:
                    SystemUiOverlayStyle(statusBarColor: Colors.grey[200]),
                backgroundColor: const Color.fromARGB(255, 232, 231, 231),
                elevation: 0,
                titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              buttonTheme: const ButtonThemeData(
                buttonColor: Colors.deepOrange,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                // fillColor: Colors.black,
                hintStyle: TextStyle(
                  color: Colors.black,
                ),
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Colors.white,
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                labelStyle: TextStyle(color: Colors.white),
              ),
              // textTheme:
              //     const TextTheme(bodyText2: TextStyle(color: Colors.white)),
              buttonTheme: const ButtonThemeData(
                buttonColor: Colors.deepOrange,
              ),
              appBarTheme: AppBarTheme(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                color: HexColor("353232"),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(color: Color(0x00ffffff), fontSize: 20),
                  ),
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.deepOrange,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  backgroundColor: HexColor("353232")),
              scaffoldBackgroundColor: HexColor("353232"),

              textTheme: const TextTheme(
                bodyText1: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            home: const ManageProducts(),
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
