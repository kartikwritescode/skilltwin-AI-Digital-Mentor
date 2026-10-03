import 'package:flutter/material.dart';
import '../../core/navigation/skilltwin_page_transitions.dart';

/// Centralized, production-grade color palette for SkillTwin.
/// Preserves brand identity (Midnight Navy / Soft Violet / Fresh Mint)
/// while enforcing WCAG-compliant contrast and calm educational aesthetics.
abstract class AppColors {
  // Base Surfaces
  static const Color background = Color(0xFFF8F9FD); // Warm White / Soothing light lavender
  static const Color surface = Color(0xFFFFFFFF); // Clean pure white cards
  static const Color elevatedSurface = Color(0xFFFFFFFF); // Elevated surface (calm, un-tinted)
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Light slate subtle contrast surface

  // Brand Colors
  static const Color primary = Color(0xFF1E2238); // Deep Indigo / Midnight Navy
  static const Color secondary = Color(0xFF6366F1); // Soft Violet / Indigo (primary actionable)
  static const Color accent = Color(0xFF38BDF8); // Electric Sky / Periwinkle Accent

  // Text Colors (High & WCAG Accessible Contrast)
  static const Color textPrimary = Color(0xFF0F172A); // Midnight Slate (near-black for primary readability)
  static const Color textSecondary = Color(0xFF475569); // Slate Body (comfortable reading contrast)
  static const Color mutedText = Color(0xFF94A3B8); // Soft Muted Helper / Hint Text

  // Dividers & Outlines
  static const Color border = Color(0xFFE2E8F0); // Subtle 1px boundary
  static const Color borderSubtle = Color(0xFFF1F5F9); // Ultra-light divider

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald / Fresh Mint
  static const Color warning = Color(0xFFF59E0B); // Warm Amber
  static const Color error = Color(0xFFEF4444); // Clear Coral Red

  // Mascot Companion Accent
  static const Color mascotAccent = Color(0xFFFF7A00); // Warm character fur accent
}

/// Standardized spacing system using strict, predictable scales.
/// Eliminates arbitrary padding and keeps mobile screens uniform.
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen & Component Standard Offsets
  static const double screenPadding = 16.0;
  static const double screenPaddingWide = 20.0;
  static const double cardPadding = 16.0;
  static const double cardRadius = 16.0;

  /// Dedicated safe bottom scroll padding to prevent content from hiding
  /// underneath the floating bottom navigation bar.
  /// Minimal spacing: just enough to clear the nav bar.
  static const double bottomNavPadding = 84.0;

  /// Navigation bar container height in MainWrapper (line 44)
  static const double floatingNavContainerHeight = 0.0;

  /// Navigation bar bottom padding in MainWrapper (line 27)
  static const double floatingNavBottomPadding = 12.0;

  /// Minimal breathing space above nav bar (clean, tight spacing)
  static const double navBarBreathingSpace = 8.0;

  /// Calculates minimal bottom inset to sit just above the navigation bar.
  ///
  /// Formula: MediaQuery.safeArea + nav container (72px) + nav padding (12px) + breathing space (8px)
  ///
  /// This ignores the FAB (which is positioned separately and floats above content).
  ///
  /// Results:
  /// - Standard device: 0 + 72 + 12 + 8 = 92px
  /// - Device with gesture bar (20px): 20 + 72 + 12 + 8 = 112px
  /// - iPhone with notch (34px): 34 + 72 + 12 + 8 = 126px
  static double calculateBottomNavInset(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    return safeAreaBottom  ;
        // + floatingNavBottomPadding + navBarBreathingSpace;
  }

  /// Calculates responsive horizontal padding (16-24px):
  /// - < 360px: 16px (compact viewports)
  /// - 360-600px: 20px (standard mobile)
  /// - > 600px: 24px (tablets / desktop)
  static double responsiveHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 600) return 24.0;
    if (width < 360) return 16.0;
    return 20.0;
  }

  // Reusable EdgeInsets Shortcuts
  static const EdgeInsets edgeXs = EdgeInsets.all(xs);
  static const EdgeInsets edgeSm = EdgeInsets.all(sm);
  static const EdgeInsets edgeMd = EdgeInsets.all(md);
  static const EdgeInsets edgeLg = EdgeInsets.all(lg);
  static const EdgeInsets screenInsets = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets screenScrollInsets = EdgeInsets.fromLTRB(screenPadding, sm, screenPadding, bottomNavPadding);
}

/// Coherent, mobile-optimized typography hierarchy.
/// Emphasizes readability, gentle line heights, and restrained weights (no excessive w800).
abstract class AppTypography {
  /// Large onboarding & hero statements. Strong, friendly, never excessively bold.
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Screen titles and prominent questions.
  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Card section titles and secondary headers.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// Core learning body text, explanations, and descriptions.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Emphasized body text (medium weight).
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  /// Compact body text for dense lists or secondary paragraphs.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Metadata, hints, badges, and helper text.
  static const TextStyle supporting = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.35,
    color: AppColors.mutedText,
  );

  /// Medium-weight button labels.
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.25,
    color: Colors.white,
  );

  /// Small tags & category labels.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.textSecondary,
  );
}

/// Backwards-compatible facade and central ThemeData provider.
class AppTheme {
  // Aliases for AppColors
  static const Color primary = AppColors.primary;
  static const Color primaryAccent = AppColors.secondary;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color accentBlue = AppColors.accent;
  static const Color accentCyan = AppColors.accent;
  static const Color positive = AppColors.success;
  static const Color positiveMint = AppColors.success;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color highlightPink = Color(0xFFF472B6);
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color elevatedSurface = AppColors.elevatedSurface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.mutedText;
  static const Color mutedText = AppColors.mutedText;
  static const Color border = AppColors.border;
  static const Color cardBorder = AppColors.border;
  static const Color mascotAccent = AppColors.mascotAccent;

  // Aliases for AppSpacing
  static const double space4 = AppSpacing.xs;
  static const double space8 = AppSpacing.sm;
  static const double space12 = 12.0;
  static const double space16 = AppSpacing.md;
  static const double space20 = 20.0;
  static const double space24 = AppSpacing.lg;
  static const double space32 = AppSpacing.xl;
  static const double space40 = 40.0;
  static const double space48 = AppSpacing.xxl;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        primary: AppColors.secondary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineMedium: AppTypography.headline,
        headlineSmall: AppTypography.headlineSmall,
        bodyLarge: AppTypography.bodyMedium,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.supporting,
        labelSmall: AppTypography.label,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.headline,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.secondary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.supporting,
        labelStyle: AppTypography.bodySmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.2),
          textStyle: AppTypography.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SkillTwinCarouselPageTransitionsBuilder(),
          TargetPlatform.iOS: SkillTwinCarouselPageTransitionsBuilder(),
          TargetPlatform.windows: SkillTwinCarouselPageTransitionsBuilder(),
          TargetPlatform.macOS: SkillTwinCarouselPageTransitionsBuilder(),
          TargetPlatform.linux: SkillTwinCarouselPageTransitionsBuilder(),
          TargetPlatform.fuchsia: SkillTwinCarouselPageTransitionsBuilder(),
        },
      ),
    );
  }
}
