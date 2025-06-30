import 'package:flutter/material.dart';
import 'package:idl_sys_app/pages/Admin/adminDashboardShell.dart';
import 'package:idl_sys_app/pages/Admin/approved_Id.dart';
import 'package:idl_sys_app/pages/Student/homePage.dart';
import 'package:idl_sys_app/pages/Student/stuFeedback.dart';
import 'package:idl_sys_app/pages/loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "IDL sys",
      home: Homepage(),
      routes: {
        '/feedback': (context) => StufeedbackPage(),
        '/login': (context) => LoginPage(),
        '/homePage': (context) => Homepage(),
        '/dashBoard': (context) => AdminDashboardShell(),
        'approvedIDs': (context) => ApprovedIDsPage(),
      },
    );
  }
}
