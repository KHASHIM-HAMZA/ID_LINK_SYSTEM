import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Digitalid extends StatefulWidget {
  final String regNo;

  const Digitalid({super.key, required this.regNo});

  @override
  State<Digitalid> createState() => _DigitalidState();
}

class _DigitalidState extends State<Digitalid> {
  late String imageUrl;
  late String pdfUrl;
  bool useImage = true;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    imageUrl = '${AppConfig.baseUrl}/Uploads/idcards/${widget.regNo}.png';
    pdfUrl = '${AppConfig.baseUrl}/Uploads/idcards/${widget.regNo}.pdf';
  }

  Future<String> _downloadFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/student_id_${widget.regNo}.pdf";
      final file = File(path);

      if (await file.exists()) return file.path;

      setState(() => isDownloading = true);
      final bytes = await ApiService.getBinary(
        'Uploads/idcards/${widget.regNo}.pdf',
      );
      await file.writeAsBytes(bytes);
      return path;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Download failed: $e"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return '';
    } finally {
      setState(() => isDownloading = false);
    }
  }

  void _onDownload() async {
    final path = await _downloadFile();
    if (path.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ File downloaded successfully"),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _onShare() async {
    final path = await _downloadFile();
    if (path.isNotEmpty) {
      Share.shareXFiles([XFile(path)], text: 'Here is my Digital Student ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    final toggleIcon =
        useImage ? Icons.picture_as_pdf_rounded : Icons.image_rounded;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Digital ID"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(toggleIcon, color: Colors.white),
            onPressed: () => setState(() => useImage = !useImage),
            tooltip: useImage ? "View as PDF" : "View as Image",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child:
                      useImage
                          ? CachedNetworkImage(
                            key: const ValueKey('image'),
                            imageUrl: imageUrl,
                            placeholder:
                                (_, __) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green.shade700,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (_, __, ___) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 80,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Failed to load image",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            fit: BoxFit.contain,
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 500),
                          )
                          : PDF()
                              .cachedFromUrl(
                                pdfUrl,
                                key: const ValueKey('pdf'),
                                placeholder:
                                    (progress) => Center(
                                      child: CircularProgressIndicator(
                                        value: progress / 100,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.green.shade700,
                                            ),
                                      ),
                                    ),
                                errorWidget:
                                    (error) => Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          size: 80,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Failed to load PDF",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                              )
                              .animate()
                              .fadeIn(
                                duration: const Duration(milliseconds: 500),
                              ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child:
                isDownloading
                    ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade700,
                      ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 300),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onDownload,
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: const Text("Download"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onShare,
                            icon: const Icon(Icons.share_rounded, size: 20),
                            label: const Text("Share"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ).animate().slideY(
                      begin: 0.2,
                      end: 0,
                      duration: const Duration(milliseconds: 400),
                    ),
          ),
        ],
      ),
    );
  }
}
