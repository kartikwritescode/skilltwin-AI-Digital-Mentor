import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/models/goal.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _customTargetController =
      TextEditingController();
  final TextEditingController _knowledgeController = TextEditingController();

  String _targetLevel = 'Intermediate';
  DateTime _deadline = DateTime.now().add(const Duration(days: 90));
  String _dailyTime = '30 mins';
  int _dailyMinutes = 30;
  final List<String> _knowledgeTags = [];

  final List<String> _levelOptions = [
    'Beginner',
    'Intermediate',
    'Expert',
    'Interview Ready',
    'Other',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _goalController.dispose();
    _customTargetController.dispose();
    _knowledgeController.dispose();
    super.dispose();
  }

  void _next() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep < 5) {
      ref.read(onboardingProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    final customTarget = _targetLevel == 'Other' ||
            _customTargetController.text.trim().isNotEmpty
        ? _customTargetController.text.trim()
        : null;

    final goal = Goal(
      id: '',
      title: _goalController.text.trim(),
      targetLevel: _targetLevel,
      customTarget: customTarget,
      deadline: _deadline,
      dailyMinutes: _dailyMinutes,
      dailyTime: _dailyTime,
      existingKnowledge: _knowledgeTags,
    );

    ref.read(onboardingProvider.notifier).updateGoal(goal);
    ref.read(onboardingProvider.notifier).submitGoal();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    if (state.isLoading) {
      return const _LoadingOverlay();
    }

    final isNextEnabled = _canProceed(state.currentStep);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: state.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  ref.read(onboardingProvider.notifier).previousStep();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                },
              )
            : null,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (state.currentStep + 1) / 6,
            minHeight: 6,
            backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: isNextEnabled ? _next : null,
              child: Text(
                state.currentStep == 5 ? 'CREATE ROADMAP' : 'NEXT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isNextEnabled
                      ? const Color(0xFFFF6D00)
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
          _buildStep4(),
          _buildStep5(),
          _buildStep6(),
        ],
      ),
    );
  }

  bool _canProceed(int step) {
    switch (step) {
      case 0:
        return _goalController.text.trim().isNotEmpty;
      case 1:
        if (_targetLevel == 'Other') {
          return _customTargetController.text.trim().isNotEmpty;
        }
        return true;
      default:
        return true;
    }
  }

  Widget _buildStep1() {
    return _StepLayout(
      title: "What do you want to learn?",
      subtitle:
          "Type any topic, framework, field, or career goal. SkillTwin creates a fully personalized learning path.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _goalController,
            maxLines: 3,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 17, height: 1.4),
            decoration: InputDecoration(
              hintText:
                  "e.g. Master Backend Engineering with Python & FastAPI, or Quantum Computing Fundamentals",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "QUICK INSPIRATION",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Full-Stack Web Development',
              'Cloud Architecture & DevOps',
              'System Design & Microservices',
              'Machine Learning & Deep Learning',
              'Data Structures & Algorithms',
              'Generative AI Applications',
            ].map((e) => ActionChip(
                  label: Text(e),
                  backgroundColor: _goalController.text == e
                      ? const Color(0xFFFF6D00).withValues(alpha: 0.12)
                      : Colors.white,
                  side: BorderSide(
                    color: _goalController.text == e
                        ? const Color(0xFFFF6D00)
                        : Colors.grey.shade300,
                  ),
                  labelStyle: TextStyle(
                    color: _goalController.text == e
                        ? const Color(0xFFFF6D00)
                        : Colors.black87,
                    fontWeight: _goalController.text == e
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12.5,
                  ),
                  onPressed: () {
                    setState(() {
                      _goalController.text = e;
                    });
                  },
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _StepLayout(
      title: "What is your target level?",
      subtitle:
          "Choose your target mastery depth so SkillTwin generates the optimal scope.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._levelOptions.map((level) {
            final isSelected = _targetLevel == level;
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6D00)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                title: Text(
                  level,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFFF6D00)
                        : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  _getLevelDescription(level),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                value: level,
                activeColor: const Color(0xFFFF6D00),
                groupValue: _targetLevel,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _targetLevel = val);
                  }
                },
              ),
            );
          }),
          if (_targetLevel == 'Other' ||
              _targetLevel == 'Interview Ready') ...[
            const SizedBox(height: 12),
            const Text(
              "CUSTOM OUTCOME / SPECIFIC TARGET",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customTargetController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "e.g. Pass Google Senior L5 system design interview",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFFF6D00), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'Beginner':
        return 'Foundational concepts, syntax, and fundamental workflows';
      case 'Intermediate':
        return 'Practical applications, best practices, and core projects';
      case 'Expert':
        return 'Advanced architecture, performance optimization, and internals';
      case 'Interview Ready':
        return 'High-frequency interview questions, edge cases, and design';
      case 'Other':
        return 'Specify a tailored custom target outcome';
      default:
        return '';
    }
  }

  Widget _buildStep3() {
    return _StepLayout(
      title: "Target completion date?",
      subtitle:
          "Pacing adjusts dynamically to keep your daily practice realistic and sustainable.",
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: CalendarDatePicker(
          initialDate: _deadline,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          onDateChanged: (date) => setState(() => _deadline = date),
        ),
      ),
    );
  }

  Widget _buildStep4() {
    final options = [
      {'label': '15 mins/day', 'minutes': 15},
      {'label': '30 mins/day', 'minutes': 30},
      {'label': '45 mins/day', 'minutes': 45},
      {'label': '1 hour/day', 'minutes': 60},
      {'label': '2 hours/day', 'minutes': 120},
    ];

    return _StepLayout(
      title: "Daily time commitment?",
      subtitle:
          "Short daily sessions produce far higher retention than weekend marathons.",
      child: Column(
        children: options.map((opt) {
          final label = opt['label'] as String;
          final mins = opt['minutes'] as int;
          final isSelected = _dailyMinutes == mins;

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF6D00)
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<int>(
              title: Text(
                label,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFF6D00)
                      : Colors.black87,
                ),
              ),
              value: mins,
              groupValue: _dailyMinutes,
              activeColor: const Color(0xFFFF6D00),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _dailyMinutes = val;
                    _dailyTime = label;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep5() {
    return _StepLayout(
      title: "Existing knowledge?",
      subtitle:
          "List skills you already understand so your curriculum doesn't waste time on basics.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _knowledgeController,
                  decoration: InputDecoration(
                    hintText: "e.g. Python, SQL, Git, Linux",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (val) => _addKnowledgeTag(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _addKnowledgeTag,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_knowledgeTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _knowledgeTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                            const Color(0xFFFF6D00).withValues(alpha: 0.1),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onDeleted: () =>
                            setState(() => _knowledgeTags.remove(tag)),
                      ))
                  .toList(),
            )
          else
            Text(
              "No prior knowledge added. We'll start from the absolute ground up.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
        ],
      ),
    );
  }

  void _addKnowledgeTag() {
    final text = _knowledgeController.text.trim();
    if (text.isNotEmpty && !_knowledgeTags.contains(text)) {
      setState(() {
        _knowledgeTags.add(text);
        _knowledgeController.clear();
      });
    }
  }

  Widget _buildStep6() {
    final customTarget = _customTargetController.text.trim();

    return _StepLayout(
      title: "Ready to generate your path",
      subtitle:
          "Review your goal parameters. Your AI Mentor will build a deep hierarchical curriculum.",
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewItem("LEARNING GOAL", _goalController.text),
            const Divider(height: 28),
            _buildReviewItem("TARGET LEVEL", _targetLevel),
            if (customTarget.isNotEmpty) ...[
              const Divider(height: 28),
              _buildReviewItem("CUSTOM OUTCOME", customTarget),
            ],
            const Divider(height: 28),
            _buildReviewItem(
                "TARGET DEADLINE", "${_deadline.toLocal()}".split(' ')[0]),
            const Divider(height: 28),
            _buildReviewItem("DAILY PACE", "$_dailyMinutes minutes daily"),
            if (_knowledgeTags.isNotEmpty) ...[
              const Divider(height: 28),
              _buildReviewItem(
                  "PRIOR KNOWLEDGE", _knowledgeTags.join(', ')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}

class _StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepLayout({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: const Color(0xFF212121),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Generating your personalized curriculum...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Structuring sections, granular topics, and prerequisite graphs.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
