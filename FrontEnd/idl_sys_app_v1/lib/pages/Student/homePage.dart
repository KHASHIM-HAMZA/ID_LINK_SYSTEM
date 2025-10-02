import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/pages/Student/Check_status.dart';
import 'package:idl_sys_app_v1/pages/Student/create_request.dart';
import 'package:idl_sys_app_v1/pages/Student/digitalID.dart';
import 'package:idl_sys_app_v1/pages/Student/home.dart';
import 'package:idl_sys_app_v1/pages/Student/profile.dart';
import 'package:idl_sys_app_v1/pages/Student/report.dart';
import 'package:idl_sys_app_v1/pages/Student/stu_message.dart';
import 'package:idl_sys_app_v1/pages/Student/qr_scanner.dart'; // Add this import
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Homepage extends StatefulWidget {
  final Map userData;

  const Homepage({super.key, required this.userData});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  bool isDarkMode = false;
  late final List<Widget> pages;
  Map<String, dynamic> studentData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(userData: widget.userData),
      Profile(userData: widget.userData),
      const QrScanner(),
      StuMessages(regNo: widget.userData['regNumber'] ?? ''),
      Digitalid(regNo: widget.userData['regNumber'] ?? ''),
    ];
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final data = await ApiService.get('api/student/status');
      setState(() {
        studentData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Failed to load data: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateBottomBar(int index) {
    if (index >= 0 && index < pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('userData');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showErrorSnackbar('Logout failed: $e');
    }
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final regNumber = user['regNumber'] ?? '';
    final imageUrl =
        '${AppConfig.baseUrl}/api/student/uploads/photos?regNumber=$regNumber';

    final themeData =
        isDarkMode
            ? ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: Colors.black,
            )
            : ThemeData.light().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: const Color.fromARGB(255, 189, 178, 178),
            );

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("IDL-SYSTEM"),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStudentData,
              tooltip: 'Refresh Data',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user['fullName'] ?? 'No name'),
                accountEmail: Text(user['regNumber'] ?? 'No regNo'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(imageUrl),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person),
                ),
                decoration: const BoxDecoration(color: Colors.green),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text("Toggle Theme"),
                onTap: _toggleTheme,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.track_changes_outlined),
                title: const Text("ID Status"),
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => IDRequestStatus(regNumber: regNumber),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem),
                title: const Text("Report Lost ID"),
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LossReportPage(), // Navigate to new page
                    ),
                  );
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
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(index: _selectedIndex, children: pages),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed:
              () => showDialog(
                context: context,
                builder: (context) => const CreateRequest(),
              ),
          child: const Icon(Icons.add),
          tooltip: 'New Request',
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _navigateBottomBar,
          currentIndex: _selectedIndex.clamp(0, pages.length - 1),
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
              icon: Icon(Icons.message),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Digital ID",
            ),
          ],
        ),
      ),
    );
  }
}
