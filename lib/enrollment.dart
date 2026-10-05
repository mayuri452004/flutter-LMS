import 'package:flutter/material.dart';

class enrollment extends StatefulWidget {
  const enrollment({super.key});

  @override
  State<enrollment> createState() => _enrollmentState();
}

class _enrollmentState extends State<enrollment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Text("enrollment"),
      ) ,
    );
  }
}