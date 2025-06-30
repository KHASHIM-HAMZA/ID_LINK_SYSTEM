import 'package:flutter/material.dart';
import 'package:idl_sys_app/pages/Admin/adminMessagesPage.dart';
import 'package:idl_sys_app/pages/Admin/approved_Id.dart';
import 'package:idl_sys_app/pages/Admin/viewRequest.dart';

class AdminDashboardShell extends StatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  int selectedPageIndex = 0;

  final List<Widget> pages = [
    viewRequest(),
    ApprovedIDsPage(),
    AdminMessagesPage(),
    Center(child: Text("Status Page coming soon")),
  ];

  final List<String> titles = [
    'Pending ID Requests',
    'Approved IDs',
    'Student Messages',
    'Status Page',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedPageIndex]),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _buildDrawerItem(Icons.list, "View Requests", 0),
            _buildDrawerItem(Icons.check_circle, "Approved IDs", 1),
            _buildDrawerItem(Icons.message, "Messages", 2),
            _buildDrawerItem(Icons.info_outline, "Status", 3),
          ],
        ),
      ),
      body: pages[selectedPageIndex],
    );
  }

  ListTile _buildDrawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selectedPageIndex == index,
      onTap: () {
        setState(() {
          selectedPageIndex = index;
        });
        Navigator.pop(context); // close drawer
      },
    );
  }
}
