import 'package:flutter/material.dart';
import 'package:spike_plan/taskview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AISSP',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: TaskView(),
    );
  }
}

