import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';

class IDRequestStatus extends StatefulWidget {
  final String regNumber;
  const IDRequestStatus({super.key, required this.regNumber});

  @override
  State<IDRequestStatus> createState() => _IDRequestStatusState();
}

class _IDRequestStatusState extends State<IDRequestStatus> {
  String _status = 'loading'; // loading, pending, printed, rejected
  DateTime? _requestDate;
  DateTime? _completionDate;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/student/id-status?regNumber=${widget.regNumber}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _status = data['status'] ?? 'pending';
          _requestDate =
              data['requestDate'] != null
                  ? DateTime.parse(data['requestDate'])
                  : DateTime.now();
          _completionDate =
              data['completionDate'] != null
                  ? DateTime.parse(data['completionDate'])
                  : null;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load status');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Custom Liquid Progress Indicator Widget
  Widget _buildCustomProgressIndicator(double value, Color color) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width * 0.8 * value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('ID Request Status'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.teal.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? _buildLoadingState()
                    : _hasError
                    ? _buildErrorState()
                    : _buildStatusContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Checking your ID status...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade700),
          const SizedBox(height: 20),
          Text(
            'Failed to load status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchStatus,
            child: const Text('Try Again'),
          ),
        ],
      ),
    ).animate().shakeX();
  }

  Widget _buildStatusContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildStatusHeader(),
        const SizedBox(height: 30),
        _buildProgressIndicator(),
        const SizedBox(height: 40),
        _buildStatusDetails(),
        const SizedBox(height: 30),
        _buildActionButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: _getStatusIcon()),
        ).animate().scale(duration: 500.ms),
        const SizedBox(height: 20),
        Text(
          _getStatusTitle(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(),
          ),
        ).animate().fadeIn(delay: 200.ms),
        Text(
          _getStatusSubtitle(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progressValue =
        {'pending': 0.3, 'printed': 1.0, 'rejected': 0.6}[_status] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildCustomProgressIndicator(
            progressValue,
            _getStatusColor(),
          ).animate().scaleX(duration: 800.ms),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStep(
                'Submitted',
                Icons.check_circle,
                _status != 'loading',
              ),
              _buildProgressStep(
                'Processing',
                Icons.autorenew,
                _status != 'pending' && _status != 'loading',
              ),
              _buildProgressStep(
                'Completed',
                Icons.verified,
                _status == 'printed' || _status == 'rejected',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? _getStatusColor() : Colors.grey.shade400,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.grey.shade800 : Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Request Date',
            _requestDate != null
                ? '${_requestDate?.day}/${_requestDate?.month}/${_requestDate?.year}'
                : '--',
            Icons.calendar_today,
          ),
          const Divider(height: 30),
          if (_completionDate != null)
            _buildDetailRow(
              'Completion Date',
              '${_requestDate?.day}/${_requestDate?.month}/${_requestDate?.year}',
              Icons.event_available,
            ),
          if (_status == 'rejected') ...[
            const Divider(height: 30),
            _buildDetailRow(
              'Reason',
              'Document verification failed',
              Icons.info_outline,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          if (_status == 'rejected')
            ElevatedButton.icon(
              onPressed: () {
                // Handle reapply action
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reapply for ID Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          if (_status == 'printed')
            ElevatedButton.icon(
              onPressed: () {
                // Handle collection action
              },
              icon: const Icon(Icons.download),
              label: const Text('Collect Your ID Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          if (_status == 'pending')
            OutlinedButton.icon(
              onPressed: () {
                // Handle contact action
              },
              icon: const Icon(Icons.message),
              label: const Text('Contact Admin About Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue.shade200),
              ),
            ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _getStatusIcon() {
    switch (_status) {
      case 'printed':
        return Icon(
          Icons.verified_user,
          size: 50,
          color: Colors.green.shade700,
        );
      case 'rejected':
        return Icon(Icons.cancel, size: 50, color: Colors.red.shade700);
      case 'pending':
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.orange.shade400, Colors.amber.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.pending_actions,
            size: 50,
            color: Colors.white,
          ),
        );
      default:
        return const Icon(Icons.help_outline, size: 50, color: Colors.grey);
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case 'printed':
        return 'ID Card Ready!';
      case 'rejected':
        return 'Request Rejected';
      case 'pending':
        return 'Processing Request';
      default:
        return 'Status Unknown';
    }
  }

  String _getStatusSubtitle() {
    switch (_status) {
      case 'printed':
        return 'Your ID card has been printed and is ready for collection';
      case 'rejected':
        return 'Your ID card request was not approved';
      case 'pending':
        return 'Your request is being processed by the administration';
      default:
        return 'Unable to determine your ID card status';
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'printed':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }
}
