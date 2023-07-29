import 'package:flutter/material.dart';
import 'package:objectsdetections/pages/tflite_home.dart';
import 'package:objectsdetections/providers/home_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const TensorFlowApp());
}

class TensorFlowApp extends StatelessWidget {
  const TensorFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter TFLite',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            appBarTheme: const AppBarTheme(elevation: 1)),
        home: const TFLiteHome(),
      ),
    );
  }
}
