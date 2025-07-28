import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/pages/Admin/admin_Dashboard.dart';
import 'package:idl_sys_app_v1/pages/Admin/approved_Id.dart';
import 'package:idl_sys_app_v1/pages/Student/feedback.dart';
import 'package:idl_sys_app_v1/pages/loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "IDL sys",
      home: LoginPage(),

      routes: {
        '/feedback': (context) => StufeedbackPage(),
        '/login': (context) => LoginPage(),
        //     '/homePage': (context) => Homepage(userData: userData),
        '/dashBoard': (context) => AdminDashboard(),
        'approvedIDs': (context) => ApprovedIDsPage(),
      },
    );
  }
}
