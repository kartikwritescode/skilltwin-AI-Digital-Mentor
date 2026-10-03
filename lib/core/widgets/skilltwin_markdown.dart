import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_theme.dart';

/// Custom inline syntax for `<u>underlined text</u>` tags.
class _UnderlineSyntax extends md.InlineSyntax {
  _UnderlineSyntax() : super(r'<u>(.*?)</u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match[1] ?? '';
    final el = md.Element.text('u', text);
    parser.addNode(el);
    return true;
  }
}

/// Custom element builder to render underline tags with [TextDecoration.underline].
class _UnderlineElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text.rich(
      TextSpan(
        text: element.textContent,
        style: (preferredStyle ?? const TextStyle()).copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Centralized, accessible, and beautifully styled Markdown renderer for SkillTwin.
/// Used for AI mentor responses, explanations, question prompts, and feedback.
///
/// Ensures **bold**, *italic*, `code`, <u>underline</u>, bullet lists, and
/// code blocks render natively rather than showing raw syntax.
class SkillTwinMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final Color? textColor;
  final bool selectable;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  const SkillTwinMarkdown({
    super.key,
    required this.data,
    this.style,
    this.textColor,
    this.selectable = false,
    this.shrinkWrap = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final defaultTextColor = textColor ?? style?.color ?? AppColors.textPrimary;
    final isDarkBackground = defaultTextColor.computeLuminance() > 0.5;

    final baseStyle = (style ?? AppTypography.body).copyWith(
      color: defaultTextColor,
    );

    final codeBg = isDarkBackground
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFF1F5F9);

    final codeTextColor = isDarkBackground
        ? const Color(0xFF93C5FD)
        : const Color(0xFF4338CA);

    final strongColor = isDarkBackground
        ? Colors.white
        : const Color(0xFF0F172A);

    final styleSheet = MarkdownStyleSheet(
      p: baseStyle,
      strong: baseStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: strongColor,
      ),
      em: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: (baseStyle.fontSize ?? 14) * 0.9,
        color: codeTextColor,
        backgroundColor: codeBg,
        fontWeight: FontWeight.w600,
      ),
      codeblockPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkBackground
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFE2E8F0),
        ),
      ),
      h1: baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 15) * 1.35,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: strongColor,
      ),
      h2: baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 15) * 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: strongColor,
      ),
      h3: baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 15) * 1.1,
        fontWeight: FontWeight.w700,
        color: strongColor,
      ),
      blockquote: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: isDarkBackground
            ? Colors.white70
            : AppColors.textSecondary,
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      blockquoteDecoration: BoxDecoration(
        border: const Border(
          left: BorderSide(
            color: AppTheme.primaryAccent,
            width: 3.5,
          ),
        ),
        color: AppTheme.primaryAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      listBullet: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryAccent,
      ),
      listIndent: 20,
      pPadding: const EdgeInsets.only(bottom: 6),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 6),
      h2Padding: const EdgeInsets.only(top: 6, bottom: 4),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 4),
    );

    Widget markdownWidget = MarkdownBody(
      data: data,
      selectable: selectable,
      shrinkWrap: shrinkWrap,
      styleSheet: styleSheet,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [_UnderlineSyntax()],
      builders: {
        'u': _UnderlineElementBuilder(),
      },
      onTapLink: (text, href, title) {
        if (href != null && href.isNotEmpty) {
          final uri = Uri.tryParse(href);
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );

    if (padding != null) {
      markdownWidget = Padding(padding: padding!, child: markdownWidget);
    }

    return markdownWidget;
  }
}
