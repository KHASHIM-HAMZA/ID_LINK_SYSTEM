import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/pages/Admin/AdminLossReportsPage.dart';
import 'package:idl_sys_app_v1/pages/Admin/ManagementPage.dart';
import 'package:idl_sys_app_v1/pages/Admin/admin_DigitalIDs.dart';
import 'package:idl_sys_app_v1/pages/Admin/admin_message.dart';
import 'package:idl_sys_app_v1/pages/Admin/approved_Id.dart';
import 'package:idl_sys_app_v1/pages/Admin/viewRequests.dart';
import 'package:idl_sys_app_v1/pages/loginPage.dart';
import 'package:idl_sys_app_v1/pages/transition%20screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedPageIndex = 0;

  final List<Widget> pages = const [
    ViewRequest(),
    ApprovedIDsPage(),
    AdminMessagesPage(),
    Center(child: Text("Status Page coming soon")),
    AdminDigitalIDs(),
    StudentManagementPage(),
    AdminLossReportsPage(),
  ];

  final List<String> titles = [
    'Pending ID Requests',
    'Approved IDs',
    'Student Messages',
    'Status Page',
    'Digital IDs',
    'Manager',
    'Loss Reports',
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransitionScreen(nextScreen: LoginPage()),
                    ),
                  );
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

  void _onPageSelect(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(titles[selectedPageIndex]),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildDrawerContent()),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(), // Sidebar instead of Drawer
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(selectedPageIndex),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: IndexedStack(
                    index: selectedPageIndex,
                    children: pages,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 230,
      color: Colors.white,
      child: _buildDrawerContent(),
    );
  }

  Widget _buildDrawerContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildDrawerItem(Icons.list_alt_rounded, "View Requests", 0),
        _buildDrawerItem(Icons.check_circle_outline_rounded, "Approved IDs", 1),
        _buildDrawerItem(Icons.markunread_mailbox_rounded, "Messages", 2),
        _buildDrawerItem(Icons.info_outline, "Status", 3),
        _buildDrawerItem(Icons.badge_rounded, "Digital IDs", 4),
        _buildDrawerItem(Icons.manage_accounts, "Manager", 5),
        _buildDrawerItem(Icons.picture_as_pdf, "Loss Reports", 6),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: _logout,
        ),
      ],
    );
  }

  ListTile _buildDrawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedPageIndex == index ? Colors.green : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight:
              selectedPageIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedPageIndex == index,
      selectedTileColor: Colors.green.withOpacity(0.1),
      onTap: () {
        _onPageSelect(index);
        if (MediaQuery.of(context).size.width < 800) {
          Navigator.pop(context); // Close drawer on mobile
        }
      },
    );
  }
}
