import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/youtube_provider.dart';
import '../providers/learning_path_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

class YouTubeImportModal extends ConsumerStatefulWidget {
  const YouTubeImportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const YouTubeImportModal(),
    );
  }

  @override
  ConsumerState<YouTubeImportModal> createState() => _YouTubeImportModalState();
}

class _YouTubeImportModalState extends ConsumerState<YouTubeImportModal> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _knowledgeController = TextEditingController();
  final List<String> _knowledgeTags = [];

  int _dailyMinutes = 30;
  String _targetLevel = 'Intermediate';
  String _pace = 'normal';
  String _revisionFrequency = 'every_few_days';
  bool _strictMode = true;

  bool _isImporting = false;
  int _importStep = 0;
  String? _errorMessage;

  final List<String> _importStages = [
    "Validating URL & extracting playlist ID...",
    "Retrieving videos via YouTube Data API v3...",
    "Preserving authoritative creator sequence...",
    "Checking curriculum cache & content hash...",
    "Gemini batch topic & prerequisite analysis...",
    "Building personalized daily study schedule...",
    "Finalizing roadmap and initializing progress...",
  ];

  @override
  void dispose() {
    _urlController.dispose();
    _knowledgeController.dispose();
    super.dispose();
  }

  bool _isValidPlaylistUrl(String url) {
    final clean = url.trim();
    if (clean.isEmpty) return false;
    if (RegExp(r'^(PL|UU|FL|RD|OLAK5uy_)[a-zA-Z0-9_-]{10,}$').hasMatch(clean)) {
      return true;
    }
    return clean.contains('list=') && (clean.contains('youtube.com') || clean.contains('youtu.be'));
  }

  Future<void> _startImport() async {
    final url = _urlController.text.trim();
    if (!_isValidPlaylistUrl(url)) {
      setState(() {
        _errorMessage = "Please enter a valid YouTube playlist URL.";
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
      _importStep = 0;
    });

    // Animate through import stages
    final timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (mounted && _importStep < _importStages.length - 1) {
        setState(() {
          _importStep++;
        });
      }
    });

    try {
      final repo = ref.read(youtubeRepositoryProvider);
      final result = await repo.importPlaylist(
        url: url,
        dailyMinutes: _dailyMinutes,
        targetLevel: _targetLevel,
        currentKnowledge: _knowledgeTags,
        pace: _pace,
        revisionFrequency: _revisionFrequency,
        strictMode: _strictMode,
      );

      timer.cancel();

      if (mounted) {
        ref.invalidate(activeLearningPathProvider);
        ref.invalidate(homeDashboardProvider);
        Navigator.of(context).pop();

        final title = result['title'] ?? 'YouTube Playlist';
        final videosCount = result['video_count'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Imported '$title' ($videosCount videos) into your active roadmap!",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        setState(() {
          _isImporting = false;
          _errorMessage = e.toString().replaceAll("Exception: ", "");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: _isImporting ? _buildImportingView() : _buildFormView(),
      ),
    );
  }

  Widget _buildImportingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFF0000).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFFFF0000),
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Personalizing YouTube Roadmap",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Authoritative sequence preserved • Enhancing with Gemini",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_importStep + 1) / _importStages.length,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _importStages[_importStep],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildFormView() {
    final isValid = _isValidPlaylistUrl(_urlController.text);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smart_display_rounded,
                  color: Color(0xFFFF0000),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learn from YouTube Playlist",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      "Playlist sequence is authoritative • Paced to you",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "YOUTUBE PLAYLIST URL",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "https://www.youtube.com/playlist?list=PL...",
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              prefixIcon: const Icon(Icons.link_rounded, color: Colors.grey),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _urlController.clear()),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (isValid) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 6),
                Text(
                  "Valid playlist URL • Creator order preserved",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            "DAILY STUDY COMMITMENT",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [15, 30, 45, 60, 90, 120].map((mins) {
              final isSel = _dailyMinutes == mins;
              return ChoiceChip(
                label: Text("$mins min/day"),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _dailyMinutes = mins);
                },
                selectedColor: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                side: BorderSide(
                  color: isSel ? const Color(0xFFFF6D00) : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  color: isSel ? const Color(0xFFFF6D00) : Colors.black87,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "STUDY PACE",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _pace,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'relaxed', child: Text("Relaxed (1.5x)")),
                        DropdownMenuItem(value: 'normal', child: Text("Normal (1.25x)")),
                        DropdownMenuItem(value: 'fast', child: Text("Fast (1.05x)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _pace = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REVISION FREQUENCY",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _revisionFrequency,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'every_few_days', child: Text("Every 3 days")),
                        DropdownMenuItem(value: 'weekly', child: Text("Weekly")),
                        DropdownMenuItem(value: 'none', child: Text("No revision")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _revisionFrequency = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Strict Sequence Mode",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              "Enforces creator's exact order; Video N+1 unlocks after Video N",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            value: _strictMode,
            activeColor: const Color(0xFFFF6D00),
            onChanged: (val) => setState(() => _strictMode = val),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isValid ? _startImport : null,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                "BUILD PERSONALIZED ROADMAP",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
