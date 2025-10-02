import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/Student/create_request.dart';
import 'package:idl_sys_app_v1/pages/Student/qr_scanner.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:async/async.dart';

// Custom ImageProvider to include JWT token
class AuthenticatedNetworkImage
    extends ImageProvider<AuthenticatedNetworkImage> {
  final String url;
  final String token;

  AuthenticatedNetworkImage(this.url, this.token);

  @override
  Future<AuthenticatedNetworkImage> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<AuthenticatedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AuthenticatedNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(
    AuthenticatedNetworkImage key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading image: $e');
      // Fallback to default image
      final byteData = await rootBundle.load('assets/default_profile.png');
      final bytes = byteData.buffer.asUint8List();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    }
  }
}

class Home extends StatelessWidget {
  final Map userData;

  const Home({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    print('userData: $userData'); // Debug to check fullName
    final regNumber = userData['regNumber'] ?? '';
    final imageUrl =
        '${AppConfig.baseUrl}/api/student/uploads/photos?regNumber=$regNumber';

    return FutureBuilder<Map<String, String>>(
      future: ApiService.getHeaders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final headers = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: CustomScrollView(
            slivers: [
              // Header Sliver
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade700, Colors.green.shade500],
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24,
                      bottom: 24,
                      right: 24,
                    ),
                    alignment: Alignment.bottomLeft,
                    child: _buildWelcomeSection(imageUrl, headers),
                  ),
                ),
                elevation: 0,
              ),

              // Content Sliver
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Stats Cards
                    _buildStatsRow(),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildSectionHeader('Quick Actions'),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildSectionHeader('Recent Activities'),
                    const SizedBox(height: 16),
                    _buildRecentActivities(),
                    const SizedBox(height: 24),

                    // System Status
                    _buildSectionHeader('System Status'),
                    const SizedBox(height: 16),
                    _buildSystemStatusCard(),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(String imageUrl, Map<String, String> headers) {
    final token = headers['Authorization']?.replaceFirst('Bearer ', '') ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AuthenticatedNetworkImage(imageUrl, token),
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Failed to load profile image: $exception');
                    },
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.green,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .scale(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userData['userData']?['fullName'] ?? 'Student',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                userData['regNumber'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ).animate().slideX(
            begin: 0.2,
            end: 0,
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Icon(Icons.star_border_rounded, color: Colors.green.shade700, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '3',
            label: 'Total Requests',
            icon: Icons.list_alt_rounded,
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            value: '0',
            label: 'Approved',
            icon: Icons.check_circle_rounded,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            value: '1',
            label: 'Pending',
            icon: Icons.pending_rounded,
            color: Colors.orange.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          icon: Icons.add_circle_outline_rounded,
          color: Colors.green.shade700,
          label: 'New Request',
          onTap:
              () => showDialog(
                context: context,
                builder: (context) => const CreateRequest(),
              ),
        ),
        _buildActionCard(
          context,
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.blue.shade600,
          label: 'Scan QR',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScanner()),
              ),
        ),
        _buildActionCard(
          context,
          icon: Icons.history_rounded,
          color: Colors.orange.shade600,
          label: 'History',
          onTap: () {},
        ),
        _buildActionCard(
          context,
          icon: Icons.message_rounded,
          color: Colors.purple.shade600,
          label: 'Messages',
          onTap: () {},
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: const Duration(milliseconds: 400));
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'icon': Icons.check_circle_rounded,
        'color': Colors.green.shade600,
        'title': 'Request Approved',
        'subtitle': 'ID Card Replacement',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.pending_rounded,
        'color': Colors.orange.shade600,
        'title': 'Request Pending',
        'subtitle': 'Transcript Request',
        'time': '1 day ago',
      },
      {
        'icon': Icons.notifications_rounded,
        'color': Colors.blue.shade600,
        'title': 'New Notification',
        'subtitle': 'System Maintenance',
        'time': '2 days ago',
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            ...activities
                .map((activity) => _buildActivityTile(activity))
                .toList(),
            ListTile(
              title: Text(
                'View All Activities',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activity['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(activity['icon'], color: activity['color'], size: 24),
        ),
        title: Text(
          activity['title'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          activity['subtitle'],
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Text(
          activity['time'],
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    ).animate().slideX(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildSystemStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Systems Operational',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Last updated: ${DateTime.now().toString().substring(0, 10)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }
}
