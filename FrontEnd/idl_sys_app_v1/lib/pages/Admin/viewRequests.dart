import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:idl_sys_app_v1/pages/config.dart';

class ViewRequest extends StatefulWidget {
  const ViewRequest({super.key});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  List<Map<String, dynamic>> idRequests = [];
  bool isLoading = true;
  String? _searchQuery;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.get('api/admin/requests');

      if (response is List) {
        setState(() {
          idRequests =
              response.map((request) {
                final photoUrl = request['photoUrl']?.toString().trim();
                return {
                  'id': request['id'],
                  'regNumber': request['regNumber']?.toString() ?? 'N/A',
                  'fullName': request['fullName']?.toString() ?? 'N/A',
                  'course': request['course']?.toString() ?? 'N/A',
                  'yearOfStudy': request['yearOfStudy'] as int? ?? 0,
                  'email': request['email']?.toString() ?? 'N/A',
                  'phoneNo': request['phoneNo']?.toString() ?? 'N/A',
                  'photoUrl':
                      photoUrl != null && photoUrl.startsWith('/home')
                          ? 'http://localhost:8080/api/photo/${request['regNumber']}'
                          : photoUrl,
                  'status': request['status']?.toString() ?? 'Pending',
                  'requestDate': request['requestDate']?.toString(),
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
        _errorMessage = 'Failed to load requests: ${e.toString()}';
      });
      _showErrorSnackbar(_errorMessage!);
    }
  }

  Future<void> _handleRequestAction(
    Map<String, dynamic> request,
    String action,
  ) async {
    final regNumber = request['regNumber'];
    if (regNumber == 'N/A') {
      _showErrorSnackbar('Invalid request: Student data missing');
      return;
    }

    try {
      setState(() => isLoading = true);

      if (action == "Approved") {
        await ApiService.put('api/admin/requests/approve?regNumber=$regNumber');
      } else {
        await ApiService.put('api/admin/requests/reject?regNumber=$regNumber');

        // Send rejection message
        await ApiService.post('api/admin/messages/send', {
          'regNo': regNumber,
          'reply':
              "Your ID request was rejected. Please check your details and try again.",
        });
      }

      // Update local state
      setState(() {
        final index = idRequests.indexWhere((r) => r['regNumber'] == regNumber);
        if (index != -1) {
          idRequests[index]['status'] = action;
        }
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $action successfully'),
            backgroundColor:
                action == "Approved" ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to $action request: ${e.toString()}');
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
          onPressed: _loadPendingRequests,
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            insetPadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(request),
                  _buildStudentPhotoSection(request),
                  _buildStudentDetailsSection(request),
                  _buildActionButtons(request),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDialogHeader(Map<String, dynamic> request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ID Request Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPhotoSection(Map<String, dynamic> request) {
    final photoUrl = request['photoUrl'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<Map<String, String>>(
              future: ApiService.getHeaders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  print('Headers error or not available for URL: $photoUrl');
                  return const Icon(Icons.person, size: 50);
                }

                final headers = snapshot.data!;
                final token = headers['Authorization']?.replaceFirst(
                  'Bearer',
                  '',
                );
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photoUrl ?? '',
                    fit: BoxFit.cover,
                    headers: headers,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error: $error for URL: $photoUrl');
                      return const Icon(Icons.person, size: 50);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            request['fullName'],
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            request['regNumber'],
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetailsSection(Map<String, dynamic> request) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Course:', request['course']),
          _buildDetailRow('Year of Study:', 'Year ${request['yearOfStudy']}'),
          _buildDetailRow('Email:', request['email']),
          _buildDetailRow('Phone:', request['phoneNo']),
          _buildDetailRow('Status:', request['status']),
          _buildDetailRow('Request Date:', _formatDate(request['requestDate'])),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> request) {
    if (request['status'] != 'Pending') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'This request has already been ${request['status'].toString().toLowerCase()}',
          style: TextStyle(
            color: request['status'] == 'Approved' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _handleRequestAction(request, "Rejected"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Reject"),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _handleRequestAction(request, "Approved"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
      } catch (e) {
        return date;
      }
    }
    return "Unknown date";
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return idRequests
          .where((request) => request['status'] == "Pending")
          .toList();
    }
    return idRequests.where((request) {
      return request['status'] == "Pending" &&
          (request['fullName'].toString().toLowerCase().contains(
                _searchQuery!.toLowerCase(),
              ) ||
              request['regNumber'].toString().toLowerCase().contains(
                _searchQuery!.toLowerCase(),
              ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search pending requests...',
                          border: InputBorder.none,
                        ),
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadPendingRequests,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending: ${_filteredRequests.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Total: ${idRequests.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRequests.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_outlined, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery?.isNotEmpty == true
                                ? 'No matching requests found'
                                : 'No pending ID requests',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (_searchQuery?.isNotEmpty == true)
                            TextButton(
                              onPressed:
                                  () => setState(() => _searchQuery = null),
                              child: const Text('Clear search'),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = _filteredRequests[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showRequestDetails(request),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request['fullName'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          request['regNumber'],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${request['course']} • Year ${request['yearOfStudy']}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
