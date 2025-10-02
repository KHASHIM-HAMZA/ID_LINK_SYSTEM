import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:idl_sys_app_v1/pages/config.dart';

class ApprovedIDsPage extends StatefulWidget {
  const ApprovedIDsPage({super.key});

  @override
  State<ApprovedIDsPage> createState() => _ApprovedIDsPageState();
}

class _ApprovedIDsPageState extends State<ApprovedIDsPage> {
  List<Map<String, dynamic>> approvedIds = [];
  bool isLoading = true;
  String? _searchQuery;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApprovedIds();
  }

  Future<void> _loadApprovedIds() async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.get('api/admin/approved');

      if (response is List) {
        setState(() {
          approvedIds =
              response.map((item) {
                return {
                  'fullName': item['fullName']?.toString() ?? 'Unknown',
                  'regNumber': item['regNumber']?.toString() ?? 'Unknown',
                  'course': item['course']?.toString() ?? 'Unknown',
                  'yearOfStudy': item['yearOfStudy'] as int? ?? 0,
                  'status': item['status']?.toString() ?? 'Approved',
                  'photoUrl': item['photoUrl']?.toString(),
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Failed to load approved IDs: ${e.toString()}';
      });
      _showErrorSnackbar(_errorMessage!);
    }
  }

  Future<void> _printId(String regNumber) async {
    try {
      setState(() => isLoading = true);
      await ApiService.put('api/print/mark-printed?regNumber=$regNumber');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Print request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Update local status without refetching
        setState(() {
          final index = approvedIds.indexWhere(
            (id) => id['regNumber'] == regNumber,
          );
          if (index != -1) {
            approvedIds[index]['status'] = 'Printed';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to print ID: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadApprovedIds,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredIds {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return approvedIds;
    }
    final query = _searchQuery!.toLowerCase();
    return approvedIds.where((id) {
      return id['fullName'].toString().toLowerCase().contains(query) ||
          id['regNumber'].toString().toLowerCase().contains(query) ||
          id['course'].toString().toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'printed':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'Printed';
        break;
      case 'approved':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Approved';
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStudentPhoto(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person, size: 30),
      );
    }

    final fullPhotoUrl = '${AppConfig.baseUrl}/uploads/photos/$photoUrl';

    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(fullPhotoUrl),
      backgroundColor: Colors.grey.shade200,
      onBackgroundImageError: (exception, stackTrace) {
        // Handle image loading errors
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator(
        onRefresh: _loadApprovedIds,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Approved IDs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadApprovedIds,
                  tooltip: 'Refresh',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name or registration number...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon:
                            _searchQuery?.isNotEmpty == true
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => _searchQuery = null);
                                  },
                                )
                                : null,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadApprovedIds,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredIds.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery?.isNotEmpty == true
                            ? 'No matching IDs found'
                            : 'No approved IDs available',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_searchQuery?.isNotEmpty == true)
                        TextButton(
                          onPressed: () {
                            setState(() => _searchQuery = null);
                          },
                          child: const Text('Clear search'),
                        ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final id = _filteredIds[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStudentPhoto(id['photoUrl']),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      id['fullName'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      id['regNumber'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${id['course']} • Year ${id['yearOfStudy']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(id['status']),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  // View details functionality
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                ),
                                child: const Text('View Details'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    id['status'] == 'Printed'
                                        ? null
                                        : () => _printId(id['regNumber']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Print'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _filteredIds.length),
              ),
          ],
        ),
      ),
    );
  }
}
