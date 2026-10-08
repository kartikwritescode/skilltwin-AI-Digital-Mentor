import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../providers/onboarding_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';

/// Conversational "Meet Your Twin" onboarding flow.
///
/// Designed with a minimalist vertical hierarchy:
///   [Breathing space & subtle top affordance]
///   [Central prominent mascot]
///   [One conversational question in friendly semi-bold typography]
///   [Answer / action area]
///
/// No bulky cards behind the mascot, no decorative clutter, no competing headings.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  static int? normalizeDailyMinutes(String input) =>
      _OnboardingFlowScreenState.normalizeDailyMinutes(input);

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  late final PageController _pageController;
  late final TextEditingController _customGoalController;
  late final TextEditingController _customLevelController;
  late final TextEditingController _customTimeController;

  bool _isCustomLevel = false;
  bool _isCustomTime = false;
  bool _isCustomDeadline = false;
  String? _customLevelError;
  String? _customTimeError;
  bool _isSubmitting = false;

  static const List<String> _popularGoals = [
    'Flutter & Mobile Apps',
    'Machine Learning & AI',
    'Full-Stack Web Development',
    'Python & Data Science',
    'Cloud & DevOps Architecture',
  ];

  static const List<Map<String, String>> _standardLevels = [
    {
      'title': 'Complete beginner',
      'subtitle': 'Starting fresh from zero with curiosity',
    },
    {
      'title': 'I know the basics',
      'subtitle': 'Familiar with core concepts and fundamental syntax',
    },
    {
      'title': 'Intermediate',
      'subtitle': 'Built small projects, looking for architectural depth',
    },
    {
      'title': 'Advanced',
      'subtitle': 'Experienced, polishing systems & production mastery',
    },
  ];

  static const List<Map<String, dynamic>> _quickDailyTimes = [
    {
      'minutes': 15,
      'title': '15 min',
      'subtitle': 'Quick daily habit that fits any schedule',
    },
    {
      'minutes': 30,
      'title': '30 min',
      'subtitle': 'Recommended balance for steady long-term retention',
    },
    {
      'minutes': 45,
      'title': '45 min',
      'subtitle': 'Focused momentum and deep active recall',
    },
    {
      'minutes': 60,
      'title': '60 min',
      'subtitle': 'Immersive daily learning sprint',
    },
    {
      'minutes': 90,
      'title': '90+ min',
      'subtitle': 'Accelerated mastery for fast results',
    },
  ];

  static const List<Map<String, dynamic>> _quickDeadlines = [
    {
      'days': 0,
      'title': 'No deadline',
      'subtitle': 'Learn at my own rhythm, no pressure',
    },
    {
      'days': 7,
      'title': 'Within 7 days',
      'subtitle': 'High-velocity 1-week sprint',
    },
    {
      'days': 30,
      'title': 'Within 30 days',
      'subtitle': '1-month focused milestone',
    },
    {
      'days': 60,
      'title': 'Within 60 days',
      'subtitle': '2-month consistent progression',
    },
    {
      'days': 90,
      'title': 'Within 90 days',
      'subtitle': '3-month comprehensive curriculum',
    },
  ];

  static const List<Map<String, String>> _learningMethods = [
    {
      'title': 'Read & understand',
      'subtitle': 'Clear mental models, diagrams, and concise explanations',
    },
    {
      'title': 'Practice problems',
      'subtitle': 'Hands-on debugging challenges and code diagnostics',
    },
    {
      'title': 'Build projects',
      'subtitle': 'Learn by crafting real-world functional applications',
    },
    {
      'title': 'Video resources',
      'subtitle': 'Visual lectures and walkthroughs for tricky topics',
    },
    {
      'title': 'Interactive quizzes',
      'subtitle': 'Bite-sized active checkpoints to test knowledge',
    },
    {
      'title': 'Teach it back',
      'subtitle': 'Explain concepts to your Twin to identify blindspots',
    },
    {
      'title': 'Flashcards / spaced recall',
      'subtitle': 'Algorithmic spaced repetition to prevent forgetting',
    },
    {
      'title': 'Mixed approach',
      'subtitle': 'A personalized blend adapted to each topic',
    },
  ];

  static const List<Map<String, String>> _videoPreferences = [
    {
      'title': 'Yes, show useful videos',
      'subtitle': 'Curated video explainers woven into key topics',
    },
    {
      'title': 'Only when helpful',
      'subtitle': 'Keep things text/code first, video only for visual ideas',
    },
    {
      'title': 'No, keep it focused',
      'subtitle': 'Pure text, interactive code, and diagrams — zero video distractions',
    },
  ];

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(onboardingProvider);
    _pageController = PageController(initialPage: initialState.currentStep);
    _customGoalController =
        TextEditingController(text: initialState.goal.title);

    final currentLevel = initialState.goal.currentLevel ?? 'Intermediate';
    final isStandardLevel =
        _standardLevels.any((l) => l['title'] == currentLevel);
    if (!isStandardLevel && currentLevel.isNotEmpty) {
      _isCustomLevel = true;
      _customLevelController = TextEditingController(text: currentLevel);
    } else {
      _customLevelController = TextEditingController();
    }

    final dailyMinutes = initialState.goal.dailyMinutes;
    final isQuickTime =
        _quickDailyTimes.any((t) => t['minutes'] == dailyMinutes);
    if (!isQuickTime && dailyMinutes > 0) {
      _isCustomTime = true;
      _customTimeController =
          TextEditingController(text: '$dailyMinutes minutes');
    } else {
      _customTimeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customGoalController.dispose();
    _customLevelController.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    FocusScope.of(context).unfocus();
    ref.read(onboardingProvider.notifier).setStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    final current = ref.read(onboardingProvider).currentStep;
    if (current < 7) {
      _goToStep(current + 1);
    } else {
      _submit();
    }
  }

  void _previous() {
    final current = ref.read(onboardingProvider).currentStep;
    if (current > 0) {
      _goToStep(current - 1);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    FocusScope.of(context).unfocus();
    try {
      final success = await ref.read(onboardingProvider.notifier).submitGoal();
      if (success && mounted) {
        ref.invalidate(activeLearningPathProvider);
        ref.invalidate(homeDashboardProvider);
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  static int? normalizeDailyMinutes(String input) {
    final clean = input.trim().toLowerCase();
    if (clean.isEmpty) return null;

    final directNum = int.tryParse(clean);
    if (directNum != null) {
      if (directNum >= 5 && directNum <= 480) return directNum;
      return null;
    }

    final combinedMatch = RegExp(
            r'^(\d+)\s*(?:h|hr|hrs|hour|hours)\s*(\d+)?\s*(?:m|min|mins|minute|minutes)?$')
        .firstMatch(clean);
    if (combinedMatch != null) {
      final hours = int.tryParse(combinedMatch.group(1) ?? '0') ?? 0;
      final mins = int.tryParse(combinedMatch.group(2) ?? '0') ?? 0;
      final total = (hours * 60) + mins;
      if (total >= 5 && total <= 480) return total;
      return null;
    }

    final decimalMatch =
        RegExp(r'^(\d+(?:\.\d+)?)\s*(?:h|hr|hrs|hour|hours)$')
            .firstMatch(clean);
    if (decimalMatch != null) {
      final hours = double.tryParse(decimalMatch.group(1)!);
      if (hours != null) {
        final total = (hours * 60).round();
        if (total >= 5 && total <= 480) return total;
        return null;
      }
    }

    final minuteMatch =
        RegExp(r'^(\d+)\s*(?:m|min|mins|minute|minutes)$').firstMatch(clean);
    if (minuteMatch != null) {
      final mins = int.tryParse(minuteMatch.group(1)!);
      if (mins != null && mins >= 5 && mins <= 480) return mins;
      return null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    if (_pageController.hasClients &&
        _pageController.page?.round() != state.currentStep) {
      _pageController.jumpToPage(state.currentStep);
    }

    if (state.isLoading) {
      return _buildLoadingScreen();
    }

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _previous();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SkillTwinBackground(
          child: SafeArea(
            child: Column(
            children: [
              _buildTopBar(state),
              if (state.error != null) _buildErrorBanner(state.error!),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOpeningStep(),
                    _buildGoalStep(state),
                    _buildLevelStep(state),
                    _buildDailyTimeStep(state),
                    _buildDeadlineStep(state),
                    _buildLearningMethodsStep(state),
                    _buildVideoPreferenceStep(state),
                    _buildReadyStep(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTopBar(OnboardingState state) {
    final step = state.currentStep;
    final isIntro = step == 0;
    final isReady = step == 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          if (step > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.textPrimary,
              splashRadius: 22,
              onPressed: _previous,
            )
          else
            const SizedBox(width: 44, height: 44),
          Expanded(
            child: (isIntro || isReady)
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final questionIndex = index + 1; // questions 1 through 6
                      final isCurrent = questionIndex == step;
                      final isDone = questionIndex < step;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isCurrent ? 20.0 : 6.0,
                        height: 4.0,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: isDone || isCurrent
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _submit,
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 0: WELCOME / INTRO
  // ─────────────────────────────────────────────────────────────
  Widget _buildOpeningStep() {
    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_home.webp',
      question: 'Before we start...',
      subtitle:
          "I've got a few quick questions that'll make your journey much better.",
      content: const SizedBox(height: 16),
      actionText: "Let's do it →",
      onAction: _next,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1: GOAL
  // ─────────────────────────────────────────────────────────────
  Widget _buildGoalStep(OnboardingState state) {
    final currentGoal = state.goal.title;
    final canProceed = currentGoal.trim().isNotEmpty;

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_curious.webp',
      question: 'What do you want to get really good at?',
      content: Column(
        children: [
          ..._popularGoals.map((goal) {
            final isSelected = currentGoal == goal;
            return _ConversationalChoice(
              title: goal,
              isSelected: isSelected,
              onTap: () {
                _customGoalController.text = goal;
                ref.read(onboardingProvider.notifier).setGoalTitle(goal);
              },
            );
          }),
          const SizedBox(height: 10),
          TextField(
            controller: _customGoalController,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Or type your own goal (e.g. Go backend, DevOps)',
              hintStyle:
                  const TextStyle(fontSize: 14, color: AppColors.mutedText),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 1.8),
              ),
            ),
            onChanged: (val) {
              ref.read(onboardingProvider.notifier).setGoalTitle(val);
            },
          ),
        ],
      ),
      actionText: 'Continue →',
      isActionEnabled: canProceed,
      onAction: _next,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: LEVEL ("How much do you already know?")
  // ─────────────────────────────────────────────────────────────
  Widget _buildLevelStep(OnboardingState state) {
    final currentLevel = state.goal.currentLevel ?? 'Intermediate';

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_mentor_thinking.webp',
      question: 'How much do you already know?',
      content: Column(
        children: [
          ..._standardLevels.map((lvl) {
            final title = lvl['title']!;
            final subtitle = lvl['subtitle'];
            final isSelected = !_isCustomLevel && (currentLevel == title ||
                (title == 'I know the basics' && currentLevel == 'Know the basics'));

            return _ConversationalChoice(
              title: title,
              subtitle: subtitle,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _isCustomLevel = false;
                  _customLevelError = null;
                });
                ref.read(onboardingProvider.notifier).setCurrentLevel(title);
              },
            );
          }),
          _ConversationalChoice(
            title: 'Something else',
            subtitle: 'Share your background so I can calibrate properly',
            isSelected: _isCustomLevel,
            onTap: () {
              setState(() {
                _isCustomLevel = true;
              });
              if (_customLevelController.text.isNotEmpty) {
                ref
                    .read(onboardingProvider.notifier)
                    .setCurrentLevel(_customLevelController.text);
              }
            },
          ),
          if (_isCustomLevel) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customLevelController,
              textCapitalization: TextCapitalization.sentences,
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. 2 years of Java, switching to Flutter',
                hintStyle:
                    const TextStyle(fontSize: 14, color: AppColors.mutedText),
                errorText: _customLevelError,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.secondary, width: 1.8),
                ),
              ),
              onChanged: (val) {
                if (_customLevelError != null && val.trim().isNotEmpty) {
                  setState(() {
                    _customLevelError = null;
                  });
                }
                ref.read(onboardingProvider.notifier).setCurrentLevel(val);
              },
            ),
          ],
        ],
      ),
      actionText: 'Continue →',
      onAction: () {
        if (_isCustomLevel) {
          final text = _customLevelController.text.trim();
          if (text.isEmpty) {
            setState(() {
              _customLevelError =
                  'Please describe your background to continue';
            });
            return;
          }
          ref.read(onboardingProvider.notifier).setCurrentLevel(text);
        }
        _next();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3: TIME ("How much time can we steal from your day?")
  // ─────────────────────────────────────────────────────────────
  Widget _buildDailyTimeStep(OnboardingState state) {
    final currentMinutes = state.goal.dailyMinutes;

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_motivation.webp',
      question: 'How much time can we steal from your day?',
      content: Column(
        children: [
          ..._quickDailyTimes.map((opt) {
            final minutes = opt['minutes'] as int;
            final title = opt['title'] as String;
            final subtitle = opt['subtitle'] as String;
            final isSelected = !_isCustomTime && currentMinutes == minutes;

            return _ConversationalChoice(
              title: title,
              subtitle: subtitle,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _isCustomTime = false;
                  _customTimeError = null;
                });
                ref
                    .read(onboardingProvider.notifier)
                    .setDailyMinutes(minutes);
              },
            );
          }),
          _ConversationalChoice(
            title: 'Custom',
            subtitle: 'Enter a custom study duration for your schedule',
            isSelected: _isCustomTime,
            onTap: () {
              setState(() {
                _isCustomTime = true;
              });
            },
          ),
          if (_isCustomTime) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.06),
                    AppColors.secondary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _customTimeError != null
                      ? AppColors.error.withValues(alpha: 0.6)
                      : AppColors.secondary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top: Icon + Live Minutes Display ──
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: (_customTimeError != null
                                  ? AppColors.error
                                  : AppColors.secondary)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.timer_outlined,
                          size: 24,
                          color: _customTimeError != null
                              ? AppColors.error
                              : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your daily commitment',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.goal.dailyMinutes} min / day',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _customTimeError != null
                                    ? AppColors.error
                                    : AppColors.secondary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_customTimeError == null)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Text Field ──
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _customTimeError != null
                            ? AppColors.error.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _customTimeController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type: 45 minutes, 1 hour, 2 hr 30 min...',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.mutedText.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: _customTimeError != null
                                ? AppColors.error.withValues(alpha: 0.6)
                                : AppColors.mutedText,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        isDense: false,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 14,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = normalizeDailyMinutes(val);
                        setState(() {
                          if (parsed != null) {
                            _customTimeError = null;
                            ref
                                .read(onboardingProvider.notifier)
                                .setDailyMinutes(parsed);
                          } else if (val.trim().isNotEmpty) {
                            _customTimeError =
                                'Enter a duration like "45 minutes" or "1 hr 30 min" (5–480 mins)';
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Quick Stepper Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeAdjustChip(
                          label: '15 min',
                          icon: Icons.remove_rounded,
                          onTap: () {
                            final newMins =
                                (state.goal.dailyMinutes - 15).clamp(15, 480);
                            _customTimeController.text = '$newMins minutes';
                            ref
                                .read(onboardingProvider.notifier)
                                .setDailyMinutes(newMins);
                            setState(() {
                              _customTimeError = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeAdjustChip(
                          label: '15 min',
                          icon: Icons.add_rounded,
                          onTap: () {
                            final newMins =
                                (state.goal.dailyMinutes + 15).clamp(15, 480);
                            _customTimeController.text = '$newMins minutes';
                            ref
                                .read(onboardingProvider.notifier)
                                .setDailyMinutes(newMins);
                            setState(() {
                              _customTimeError = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  if (_customTimeError != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _customTimeError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
      actionText: 'Continue →',
      onAction: () {
        if (_isCustomTime) {
          final parsed =
              normalizeDailyMinutes(_customTimeController.text.trim());
          if (parsed == null && _customTimeController.text.trim().isNotEmpty) {
            setState(() {
              _customTimeError =
                  'Please enter a valid time (e.g. "45 minutes", "1 hour", "1 hr 30 min")';
            });
            return;
          }
          if (parsed != null) {
            ref.read(onboardingProvider.notifier).setDailyMinutes(parsed);
          }
        }
        _next();
      },
    );
  }

  Widget _buildTimeAdjustChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 4: DEADLINE ("Got a deadline?")
  // ─────────────────────────────────────────────────────────────
  Widget _buildDeadlineStep(OnboardingState state) {
    final currentDeadline = state.goal.deadline;

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_journey_roadmap.webp',
      question: 'Got a deadline?',
      content: Column(
        children: [
          ..._quickDeadlines.map((opt) {
            final days = opt['days'] as int;
            final title = opt['title'] as String;
            final subtitle = opt['subtitle'] as String;

            bool isSelected;
            if (_isCustomDeadline) {
              isSelected = false;
            } else if (days == 0) {
              isSelected = currentDeadline == null ||
                  currentDeadline.difference(DateTime.now()).inDays > 300;
            } else {
              isSelected = currentDeadline != null &&
                  (currentDeadline.difference(DateTime.now()).inDays - days)
                          .abs() <=
                      3;
            }

            return _ConversationalChoice(
              title: title,
              subtitle: subtitle,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _isCustomDeadline = false;
                });
                if (days == 0) {
                  ref.read(onboardingProvider.notifier).setDeadline(
                        DateTime.now().add(const Duration(days: 365)),
                      );
                } else {
                  ref.read(onboardingProvider.notifier).setDeadline(
                        DateTime.now().add(Duration(days: days)),
                      );
                }
              },
            );
          }),
          _ConversationalChoice(
            title: _isCustomDeadline && currentDeadline != null
                ? 'Custom: ${DateFormat.yMMMd().format(currentDeadline)}'
                : 'Custom date',
            subtitle: _isCustomDeadline && currentDeadline != null
                ? '${currentDeadline.difference(DateTime.now()).inDays} days remaining'
                : 'Pick a specific completion date on the calendar',
            isSelected: _isCustomDeadline,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: currentDeadline ?? now.add(const Duration(days: 45)),
                firstDate: now.add(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 730)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.secondary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                ref.read(onboardingProvider.notifier).setDeadline(picked);
                setState(() {
                  _isCustomDeadline = true;
                });
              }
            },
          ),
        ],
      ),
      actionText: 'Continue →',
      onAction: _next,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 5: LEARNING METHODS ("How do you like learning?")
  // ─────────────────────────────────────────────────────────────
  Widget _buildLearningMethodsStep(OnboardingState state) {
    final selectedResources = state.goal.preferredResources;

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_coding.webp',
      question: 'How do you like learning?',
      content: Column(
        children: _learningMethods.map((style) {
          final title = style['title']!;
          final subtitle = style['subtitle'];
          final isSelected = selectedResources.contains(title);

          return _ConversationalChoice(
            title: title,
            subtitle: subtitle,
            isSelected: isSelected,
            isMultiSelect: true,
            onTap: () {
              final updated = List<String>.from(selectedResources);
              if (title == 'Mixed approach') {
                if (isSelected) {
                  updated.remove('Mixed approach');
                } else {
                  updated.add('Mixed approach');
                  if (!updated.contains('Practice problems')) {
                    updated.add('Practice problems');
                  }
                  if (!updated.contains('Build projects')) {
                    updated.add('Build projects');
                  }
                }
              } else {
                if (isSelected) {
                  updated.remove(title);
                } else {
                  updated.add(title);
                }
              }
              ref
                  .read(onboardingProvider.notifier)
                  .setPreferredResources(updated);
            },
          );
        }).toList(),
      ),
      actionText: 'Continue →',
      onAction: _next,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 6: YOUTUBE / RESOURCE PREFERENCE
  // ─────────────────────────────────────────────────────────────
  Widget _buildVideoPreferenceStep(OnboardingState state) {
    final currentPref = state.videoPreference;

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_cool.webp',
      question: 'Want me to bring videos into your learning path?',
      content: Column(
        children: _videoPreferences.map((opt) {
          final title = opt['title']!;
          final subtitle = opt['subtitle'];
          final isSelected = currentPref == title;

          return _ConversationalChoice(
            title: title,
            subtitle: subtitle,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(onboardingProvider.notifier)
                  .setVideoPreference(title);
            },
          );
        }).toList(),
      ),
      actionText: 'Continue →',
      onAction: _next,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 7: READY SCREEN
  // ─────────────────────────────────────────────────────────────
  Widget _buildReadyStep(OnboardingState state) {
    final goal = state.goal;
    final methods = goal.preferredResources
        .where((r) => !r.startsWith('Videos: '))
        .toList();

    return _ConversationalStepLayout(
      mascotAsset: 'assets/mascots/twin_celebrate.webp',
      question: 'Your journey is ready.',
      subtitle:
          "I've tailored your modular milestones, daily pace, and practice sessions.",
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Goal Card
            _buildHeroGoalCard(goal),

            const SizedBox(height: 12),

            // 2. Modern 2x2 Metric Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    tag: 'DAILY PACE',
                    value: '${goal.dailyMinutes} min / day',
                    helper: 'Focused micro-sessions',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.psychology_outlined,
                    iconColor: AppColors.secondary,
                    iconBg: const Color(0xFFEEF2FF),
                    tag: 'STARTING LEVEL',
                    value: goal.currentLevel ?? 'Intermediate',
                    helper: 'Calibrated baseline',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF0284C7),
                    iconBg: const Color(0xFFE0F2FE),
                    tag: 'TARGET TIMELINE',
                    value: _formatDeadline(goal.deadline),
                    helper: 'Milestone cadence',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.ondemand_video_rounded,
                    iconColor: const Color(0xFFE11D48),
                    iconBg: const Color(0xFFFFE4E6),
                    tag: 'VIDEO FOCUS',
                    value: state.videoPreference,
                    helper: 'Curated explainers',
                  ),
                ),
              ],
            ),

            if (methods.isNotEmpty) ...[
              const SizedBox(height: 12),
              // 3. Learning Methods Chips Card
              _buildLearningStylesCard(methods),
            ],

            const SizedBox(height: 12),

            // 4. Cognitive Architecture Highlights
            _buildCognitiveGuaranteeCard(),
          ],
        ),
      ),
      actionText: 'Start My Journey →',
      onAction: _submit,
    );
  }

  Widget _buildHeroGoalCard(Goal goal) {
    final title = goal.title.trim().isEmpty ? 'Custom Roadmap' : goal.title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 13,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'TARGET GOAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ready to Launch',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.3,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Personalized curriculum adapted to your background & daily rhythm.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String tag,
    required String value,
    required String helper,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              height: 1.25,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStylesCard(List<String> methods) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 14,
                  color: Color(0xFF9333EA),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CURRICULUM LEARNING MODES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: methods.map((method) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      method,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveGuaranteeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9D5FF),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5.5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'WHAT YOUR JOURNEY INCLUDES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeatureBullet(
            icon: Icons.account_tree_outlined,
            title: 'Modular Progression',
            detail: 'Step-by-step topics from core intuition to production depth.',
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.code_rounded,
            title: 'Deliberate Practice & Hints',
            detail: 'Interactive diagnostics, quizzes, and instant AI mentor guidance.',
          ),
          const SizedBox(height: 8),
          _buildFeatureBullet(
            icon: Icons.update_rounded,
            title: 'Spaced Retention Engine',
            detail: 'Adaptive decay tracking schedules revisions right on time.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: const Color(0xFF7C3AED)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Color(0xFF334155),
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return 'Self-paced';
    final difference = deadline.difference(DateTime.now()).inDays;
    if (difference > 300) {
      return 'Self-paced';
    } else if ((difference - 7).abs() <= 2) {
      return '1-Week Sprint';
    } else if ((difference - 30).abs() <= 3) {
      return '30-Day Goal';
    } else if ((difference - 60).abs() <= 4) {
      return '60-Day Goal';
    } else if ((difference - 90).abs() <= 5) {
      return '90-Day Plan';
    } else if (difference <= 0) {
      return 'Immediate';
    } else if (difference < 30) {
      return '$difference Days Target';
    } else {
      return DateFormat.yMMMd().format(deadline);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOADING VIEW
  // ─────────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/mascots/skilltwin_mascot_loading.gif',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/mascots/twin_mentor.webp',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.psychology_rounded,
                        size: 80,
                        color: AppColors.secondary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "I'm putting your journey together...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Structuring modular milestones, spaced retrieval practice, and daily actions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

/// Unified clean vertical layout:
///   [Breathing space]
///   [Central dominant mascot]
///   [Conversational question in readable semi-bold typography]
///   [Answer / action area]
///
/// Strips away excessive wrappers, heavy containers, decorative gradients,
/// and cluttered secondary badges.
class _ConversationalStepLayout extends StatelessWidget {
  final String mascotAsset;
  final String question;
  final String? subtitle;
  final Widget content;
  final String actionText;
  final VoidCallback onAction;
  final bool isActionEnabled;

  const _ConversationalStepLayout({
    required this.mascotAsset,
    required this.question,
    this.subtitle,
    required this.content,
    required this.actionText,
    required this.onAction,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotSize = (constraints.maxHeight * 0.17).clamp(90.0, 130.0);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // Centered prominent mascot with zero artificial box/panel behind it
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        mascotAsset,
                        key: ValueKey<String>(mascotAsset),
                        height: mascotSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          final fallbackPath = mascotAsset.replaceFirst(
                            'assets/mascots/',
                            'assets/images/mascot/',
                          );
                          return Image.asset(
                            fallbackPath,
                            key: ValueKey<String>(fallbackPath),
                            height: mascotSize,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.psychology_alt_rounded,
                              size: 72,
                              color: AppColors.secondary,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Conversational single question
                    Text(
                      question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Answer / action selection area
                    content,

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom action affordance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isActionEnabled ? onAction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.mutedText,
                    elevation: 2,
                    shadowColor: AppColors.secondary.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Clean conversational choice tile for answers
class _ConversationalChoice extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const _ConversationalChoice({
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.isMultiSelect = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isMultiSelect ? BorderRadius.circular(6) : null,
                color: isSelected ? AppColors.secondary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : AppColors.border,
                  width: 1.4,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
