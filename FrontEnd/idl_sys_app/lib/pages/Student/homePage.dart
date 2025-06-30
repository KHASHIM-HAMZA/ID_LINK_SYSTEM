import 'package:flutter/material.dart';
import 'package:idl_sys_app/pages/Student/createRequestDialog.dart';
import 'package:idl_sys_app/pages/Student/home.dart';
import 'package:idl_sys_app/pages/Student/profile.dart';
import 'package:idl_sys_app/pages/Student/qr_scanner.dart';
import 'package:idl_sys_app/pages/Student/stuFeedback.dart';
// import 'package:idl_sys_app/pages/Student/stuMessages.dart';
// Create this page

class Homepage extends StatefulWidget {
  const Homepage({super.key});

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

  final List<Widget> pages = [
    const Home(),
    const Profile(),
    const QrScannner(),
    const StufeedbackPage(),
    // Add a Messages screen
  ];

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ); // Navigate to login
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
        actions: const [
          Icon(Icons.logout),
          Padding(padding: EdgeInsets.only(right: 25)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("John Doe"),
              accountEmail: const Text("SUZA/2021/123"),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage(
                  'lib/components/IMG_2809.jpg',
                ), // or NetworkImage
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
              builder: (context) => Createrequestdialog(),
            ),
        child: Icon(Icons.add),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Messages",
          ),
        ],
      ),
    );
  }
}
