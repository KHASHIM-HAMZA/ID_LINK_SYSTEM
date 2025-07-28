import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    imageUrl = '${AppConfig.baseUrl}/uploads/idcards/${widget.regNo}.png';
    pdfUrl = '${AppConfig.baseUrl}/uploads/idcards/${widget.regNo}.pdf';
  }

  Future<String> _downloadFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/student_id_${widget.regNo}.pdf";
      final file = File(path);

      if (await file.exists()) return file.path;

      setState(() => isDownloading = true);
      await Dio().download(pdfUrl, path);
      return path;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Download failed: $e")));
      return '';
    } finally {
      setState(() => isDownloading = false);
    }
  }

  void _onDownload() async {
    final path = await _downloadFile();
    if (path.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ File downloaded successfully")),
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
    final toggleIcon = useImage ? Icons.picture_as_pdf : Icons.image;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Digital ID"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(toggleIcon),
            onPressed: () => setState(() => useImage = !useImage),
            tooltip: useImage ? "View as PDF" : "View as Image",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    useImage
                        ? CachedNetworkImage(
                          key: const ValueKey('image'),
                          imageUrl: imageUrl,
                          placeholder:
                              (_, __) => const CircularProgressIndicator(),
                          errorWidget:
                              (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 80),
                          fit: BoxFit.contain,
                        )
                        : PDF().cachedFromUrl(
                          pdfUrl,
                          key: const ValueKey('pdf'),
                          placeholder:
                              (progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress / 100,
                                ),
                              ),
                          errorWidget:
                              (error) => const Center(
                                child: Text("Failed to load PDF"),
                              ),
                        ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child:
                isDownloading
                    ? const CircularProgressIndicator()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _onDownload,
                          icon: const Icon(Icons.download),
                          label: const Text("Download"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _onShare,
                          icon: const Icon(Icons.share),
                          label: const Text("Share"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
