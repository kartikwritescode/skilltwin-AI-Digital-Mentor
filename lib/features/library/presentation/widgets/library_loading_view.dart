import 'package:flutter/material.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';

/// Meaningful loading state widget for the Library screen delegating to [SkillTwinLoadingView].
class LibraryLoadingView extends StatelessWidget {
  const LibraryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkillTwinLoadingView(
      message: 'Loading your learning bookshelf...',
      subMessage: 'Organizing synthesized notes, PDFs, and concepts',
    );
  }
}
