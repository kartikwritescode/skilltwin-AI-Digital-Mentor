import 'package:flutter/material.dart';

class LibraryHeaderBanner extends StatelessWidget {
  final String? guidance;

  const LibraryHeaderBanner({super.key, this.guidance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Smart Bookshelf Branding Row ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E7FF),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC7D2FE),
                    width: 1.2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/mascots/twin_mentor.webp',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.auto_stories_rounded,
                      size: 20,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMART LEARNING BOOKSHELF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F46E5),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Synthesized materials to ground your cognitive model',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Prioritized Reading from Mentor ──
        if (guidance != null && guidance!.isNotEmpty) ...[
          const SizedBox(height: 10),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFFFFBEB),
          //     borderRadius: BorderRadius.circular(14),
          //     border: Border.all(
          //       color: const Color(0xFFFDE68A),
          //       width: 1,
          //     ),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Icon(
          //         Icons.auto_awesome_rounded,
          //         color: Color(0xFFD97706),
          //         size: 16,
          //       ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Text(
          //               'PRIORITIZED FOCUS',
          //               style: TextStyle(
          //                 fontSize: 9.5,
          //                 fontWeight: FontWeight.w800,
          //                 letterSpacing: 0.6,
          //                 color: Color(0xFFB45309),
          //               ),
          //             ),
          //             const SizedBox(height: 2),
          //             Text(
          //               guidance!,
          //               style: const TextStyle(
          //                 fontSize: 12,
          //                 height: 1.35,
          //                 color: Color(0xFF451A03),
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ],
    );
  }
}
