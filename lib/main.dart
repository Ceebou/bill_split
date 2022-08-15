import 'package:bill_split/widgets/BillsWidget.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Bill Split',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
        // colorScheme: Theme.of(context).colorScheme.copyWith(
        //   primary: const Color(0xffffa305),
        //   onPrimary: const Color(0xff212121),
        //   secondary: const Color(0xff9E9E9E),
        //   onSecondary: const Color(0xff757575),
        //   tertiary: const Color(0xffBDBDBD),
        //   background: const Color(0xff212121),
        // ),
        floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme.copyWith(
          backgroundColor: Colors.amber,
          foregroundColor: const Color(0xff212121),
        ),
        brightness: Brightness.light,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
          iconTheme: Theme.of(context).iconTheme.copyWith(
            color: const Color(0xff212121),
          )
        )
      ),
      home: const BillsWidget(),
    );
  }
}
