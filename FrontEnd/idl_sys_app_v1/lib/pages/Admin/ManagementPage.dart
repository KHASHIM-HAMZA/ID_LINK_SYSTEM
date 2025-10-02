import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart'; // Adjust import based on your file location
import 'package:idl_sys_app_v1/pages/config.dart';
import 'dart:convert';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  // Form controllers
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCourse;
  int? _selectedYear;

  // Student list state
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      setState(() => _isLoading = true);
      final result = await ApiService.get(
        'api/auth/all-students',
      ); // Use ApiService
      setState(() {
        _students =
            (result as List)
                .map<Map<String, dynamic>>(
                  (student) => {
                    'regNumber': student['regNumber'],
                    'fullName': student['fullName'],
                    'email': student['email'],
                    'phone': student['phoneNo'],
                    'course': student['course'],
                    'year': student['year'],
                  },
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadStudents,
            ),
          ),
        );
      }
    }
  }

  Future<void> _addStudent() async {
    if (_selectedCourse == null || _selectedYear == null) return;

    setState(() => _isLoading = true);

    final studentData = {
      'regNumber': _regNumberController.text,
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phoneNo': _phoneController.text,
      'course': _selectedCourse!,
      'year': _selectedYear!,
    };

    try {
      await ApiService.post('api/auth/add', studentData); // Use ApiService
      setState(() {
        _students.add(studentData); // Optional: reflect locally
        _clearForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding student: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _addStudent,
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(String regNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this student?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ApiService.put(
          'api/auth/delete/$regNumber',
        ); // Use ApiService for delete
        setState(
          () => _students.removeWhere((s) => s['regNumber'] == regNumber),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting student: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _deleteStudent(regNumber),
              ),
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    _regNumberController.clear();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedCourse = null;
      _selectedYear = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Student Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStudents,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Content
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isDesktop)
              _buildDesktopLayout()
            else
              _buildMobileLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Student Form
          Flexible(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildAddStudentForm(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Student List
          Flexible(flex: 2, child: Card(child: _buildStudentList())),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildAddStudentForm(),
              ),
            ),
            const SizedBox(height: 20),
            Card(child: _buildStudentList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Add New Student', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _regNumberController,
          decoration: const InputDecoration(
            labelText: 'Registration Number',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedCourse,
          decoration: const InputDecoration(
            labelText: 'Course',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(),
          ),
          items:
              ['BITAM', 'BSE', 'BCS', 'BBA', 'BED'].map((course) {
                return DropdownMenuItem(value: course, child: Text(course));
              }).toList(),
          onChanged: (value) => setState(() => _selectedCourse = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: const InputDecoration(
            labelText: 'Year of Study',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
          ),
          items:
              [1, 2, 3, 4].map((year) {
                return DropdownMenuItem(value: year, child: Text('Year $year'));
              }).toList(),
          onChanged: (value) => setState(() => _selectedYear = value),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _addStudent,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text('Add Student'),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Student List (${_students.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child:
              _students.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No students found'),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(student['fullName']),
                        subtitle: Text(
                          '${student['regNumber']} - ${student['course']} Year ${student['year']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(student['regNumber']),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
