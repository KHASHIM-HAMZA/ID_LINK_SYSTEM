import 'package:flutter/material.dart';
import 'package:idl_sys_app/components/toDoTile.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: Text("TO DO"),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      body: ListView(children: [Todotile(), Todotile(), Todotile()]),
    );
  }
}
