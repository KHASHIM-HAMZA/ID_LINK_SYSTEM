import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/pages/Student/create_request.dart';
import 'package:idl_sys_app_v1/pages/Student/home.dart';

import 'package:idl_sys_app_v1/pages/Student/profile.dart';
import 'package:idl_sys_app_v1/pages/Student/qr_scanner.dart';
import 'package:idl_sys_app_v1/pages/Student/stu_message.dart';
// import 'package:idl_sys_app/pages/Student/stuMessages.dart';
// Create this page

class Homepage extends StatefulWidget {
  final Map userData;

  const Homepage({super.key, required this.userData});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(userData: widget.userData),
      Profile(userData: widget.userData),
      //const QrScannner(),
      StuMessages(regNo: widget.userData['regNumber']),
    ];
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 189, 178, 178),
      appBar: AppBar(
        title: const Text("IDL-SYSTEM"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user['fullName'] ?? 'No name'),
              accountEmail: Text(user['regNumber'] ?? 'No regNo'),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('lib/components/IMG_2809.jpg'),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => CreateRequest(),
            ),
        child: const Icon(Icons.add),
        tooltip: 'New Request',
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _navigateBottomBar,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
        ],
      ),
    );
  }
}
