import 'dart:async';
import 'package:flutter/material.dart';

class RoadmapGeneratingView extends StatefulWidget {
  final String goalTitle;

  const RoadmapGeneratingView({
    super.key,
    required this.goalTitle,
  });

  @override
  State<RoadmapGeneratingView> createState() => _RoadmapGeneratingViewState();
}

class _RoadmapGeneratingViewState extends State<RoadmapGeneratingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _stageTimer;
  late Timer _tipTimer;

  int _currentStageIndex = 0;
  int _currentTipIndex = 0;

  final List<_GenerationStage> _stages = [
    const _GenerationStage(
      title: "Analyzing Target Outcome",
      detail: "Deconstructing core concepts, prerequisite chains, and mastery thresholds.",
      icon: Icons.psychology_outlined,
      progress: 0.18,
    ),
    const _GenerationStage(
      title: "Structuring Modular Curriculum",
      detail: "Sequencing progressive milestones from fundamentals to production-grade patterns.",
      icon: Icons.account_tree_outlined,
      progress: 0.42,
    ),
    const _GenerationStage(
      title: "Synthesizing Practice Sessions",
      detail: "Formulating interactive retrieval diagnostics, challenges, and coding rubrics.",
      icon: Icons.code_rounded,
      progress: 0.68,
    ),
    const _GenerationStage(
      title: "Calibrating Cognitive Twin",
      detail: "Configuring personalized retention decay models and spaced revision scheduling.",
      icon: Icons.auto_graph_rounded,
      progress: 0.88,
    ),
    const _GenerationStage(
      title: "Finalizing Your Roadmap",
      detail: "Persisting curriculum to your offline-ready profile and preparing first topic.",
      icon: Icons.verified_outlined,
      progress: 0.98,
    ),
  ];

  final List<String> _learningTips = [
    "🧠 Active Recall: Testing yourself on new topics produces up to 200% greater retention than passive re-reading.",
    "⏳ Spaced Retrieval: SkillTwin schedules diagnostic reviews just before synaptic memories decay.",
    "🎯 Non-Vanity Twin: Your Cognitive Twin tracks verified conceptual understanding, not superficial streak counts.",
    "🔀 Interleaved Practice: Mixing related problem sets strengthens real-world architectural judgment.",
    "💡 Feynman Technique: Teaching concepts in your own words exposes hidden mental gaps instantly.",
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress through stages every 2.8 seconds
    _stageTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (!mounted) return;
      if (_currentStageIndex < _stages.length - 1) {
        setState(() {
          _currentStageIndex++;
        });
      }
    });

    // Rotate tips every 4 seconds
    _tipTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (!mounted) return;
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _learningTips.length;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stageTimer.cancel();
    _tipTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stages[_currentStageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 580,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),

                      // Animated Glowing Pulse Icon
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6D00).withValues(alpha: 0.25),
                                blurRadius: 28,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Icon(
                                stage.icon,
                                key: ValueKey<IconData>(stage.icon),
                                size: 40,
                                color: const Color(0xFFFF6D00),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Goal Badge
                      if (widget.goalTitle.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFF6D00).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Color(0xFFFF6D00),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.goalTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6D00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Dynamic Stage Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          stage.title,
                          key: ValueKey<String>(stage.title),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Stage Subtitle / Explanation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          stage.detail,
                          key: ValueKey<String>(stage.detail),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Smooth Progress Bar
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0.05, end: stage.progress),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: value,
                                  minHeight: 6,
                                  backgroundColor:
                                      const Color(0xFFFF6D00).withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6D00),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stage ${_currentStageIndex + 1} of ${_stages.length}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    "${(value * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6D00),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // Step Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_stages.length, (index) {
                          final isCurrent = index == _currentStageIndex;
                          final isPast = index < _currentStageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isCurrent ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isCurrent
                                  ? const Color(0xFFFF6D00)
                                  : isPast
                                      ? const Color(0xFFFF6D00).withValues(alpha: 0.4)
                                      : Colors.grey.shade300,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Engaging Pedagogical Tip Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            _learningTips[_currentTipIndex],
                            key: ValueKey<int>(_currentTipIndex),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GenerationStage {
  final String title;
  final String detail;
  final IconData icon;
  final double progress;

  const _GenerationStage({
    required this.title,
    required this.detail,
    required this.icon,
    required this.progress,
  });
}
