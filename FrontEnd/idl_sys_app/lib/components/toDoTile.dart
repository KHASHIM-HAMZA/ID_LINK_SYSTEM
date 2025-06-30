import 'package:flutter/material.dart';

class Todotile extends StatelessWidget {
  const Todotile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Container(
        child: Text("Make turtolial"),
        color: Colors.yellow,
        padding: EdgeInsets.all(26.0),
      ),
    );
  }
}
