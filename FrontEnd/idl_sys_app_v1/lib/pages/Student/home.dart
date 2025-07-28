import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Home extends StatelessWidget {
  const Home({super.key, required Map userData});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("home")));
  }
}
