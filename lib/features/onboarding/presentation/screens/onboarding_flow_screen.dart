import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/models/goal.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _knowledgeController = TextEditingController();

  String _currentLevel = 'Beginner';
  DateTime _deadline = DateTime.now().add(const Duration(days: 90));
  String _dailyTime = '1 hour';
  final List<String> _knowledgeTags = [];

  @override
  void dispose() {
    _pageController.dispose();
    _goalController.dispose();
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
    final goal = ref.read(onboardingProvider).goal.copyWith(
      title: _goalController.text,
      currentLevel: _currentLevel,
      deadline: _deadline,
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _goalController.text.isNotEmpty || state.currentStep > 0 ? _next : null,
              child: Text(
                state.currentStep == 5 ? 'FINISH' : 'NEXT',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildStep1() {
    return _StepLayout(
      title: "What are you trying to achieve?",
      subtitle: "Be as specific or general as you like. Your mentor will help refine it.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _goalController,
            maxLines: 3,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: "e.g. Become a Machine Learning Engineer",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 24),
          const Text("SUGGESTIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Become an AI/ML Engineer',
              'Crack GATE',
              'Get a software internship',
              'Learn DSA',
              'Learn Spanish',
              'Build a startup',
            ].map((e) => FilterChip(
              label: Text(e),
              selected: _goalController.text == e,
              onSelected: (selected) {
                setState(() {
                  _goalController.text = e;
                });
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _StepLayout(
      title: "What's your current level?",
      subtitle: "Honesty helps your mentor provide the right challenge.",
      child: Column(
        children: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].map((level) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RadioListTile<String>(
            title: Text(level, style: const TextStyle(fontWeight: FontWeight.w600)),
            value: level,
            groupValue: _currentLevel,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onChanged: (val) => setState(() => _currentLevel = val!),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStep3() {
    return _StepLayout(
      title: "When is your deadline?",
      subtitle: "Targeting a date helps calibrate the intensity of your journey.",
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
    return _StepLayout(
      title: "Daily available time?",
      subtitle: "Consistency is more important than intensity.",
      child: Column(
        children: ['30 mins', '1 hour', '2 hours', '4 hours+'].map((time) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RadioListTile<String>(
            title: Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
            value: time,
            groupValue: _dailyTime,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onChanged: (val) => setState(() => _dailyTime = val!),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStep5() {
    return _StepLayout(
      title: "Existing knowledge?",
      subtitle: "List any relevant skills, certifications, or resources you have.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _knowledgeController,
            decoration: InputDecoration(
              hintText: "Add skill (e.g. Python, Calculus)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.orange),
                onPressed: () {
                  if (_knowledgeController.text.isNotEmpty) {
                    setState(() {
                      _knowledgeTags.add(_knowledgeController.text);
                      _knowledgeController.clear();
                    });
                  }
                },
              ),
            ),
            onSubmitted: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  _knowledgeTags.add(val);
                  _knowledgeController.clear();
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _knowledgeTags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.orange.withOpacity(0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onDeleted: () => setState(() => _knowledgeTags.remove(tag)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return _StepLayout(
      title: "Confirm your goal",
      subtitle: "Your AI mentor will now build your personalized path.",
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewItem("GOAL", _goalController.text),
            const Divider(height: 32),
            _buildReviewItem("CURRENT LEVEL", _currentLevel),
            const Divider(height: 32),
            _buildReviewItem("DEADLINE", "${_deadline.toLocal()}".split(' ')[0]),
            const Divider(height: 32),
            _buildReviewItem("COMMITMENT", "$_dailyTime daily"),
            if (_knowledgeTags.isNotEmpty) ...[
              const Divider(height: 32),
              _buildReviewItem("PRIOR KNOWLEDGE", _knowledgeTags.join(', ')),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Your mentor is mapping your journey...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Analyzing goals, prerequisites, and learning nodes.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
