import 'package:flutter/material.dart';
import 'package:idl_sys_app/pages/Student/homePage.dart';

class feedback extends StatelessWidget {
  const feedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          },
          label: Icon(Icons.time_to_leave, color: Colors.deepOrangeAccent),
        ),
      ),
    );
  }
}
