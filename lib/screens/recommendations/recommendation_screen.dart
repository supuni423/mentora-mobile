import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recommendation.dart';
import '../../providers/recommendation_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';
import '../courses/course_detail_screen.dart';

const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _subjects = [
  'Mathematics',
  'Physics',
  'Chemistry',
  'ICT',
  'English',
  'Biology',
  'Music',
  'Business',
  'Science',
];
const _levels = [
  ('Grade 6-9 (Junior)', 'Junior'),
  ('Grade 10-11 (O/L)', 'O/L'),
  ('Grade 12-13 (A/L)', 'A/L'),
  ('Undergraduate', 'University'),
];
const _modes = ['Online', 'Physical', 'Both'];

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _budget = TextEditingController();
  final _goal = TextEditingController();
  final _city = TextEditingController();
  final Set<String> _selectedSubjects = {};
  String? _level;
  String _mode = 'Both';
  final Set<String> _selectedDays = {};

  @override
  void dispose() {
    _budget.dispose();
    _goal.dispose();
    _city.dispose();
    super.dispose();
  }

  void _submit() {
    final preferences = RecommendationPreferences(
      subjects: _selectedSubjects.toList(),
      level: _level,
      mode: _mode,
      availableDays: _selectedDays.toList(),
      budget: double.tryParse(_budget.text.trim()),
      goal: _goal.text.trim().isEmpty ? null : _goal.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
    );
    context.read<RecommendationProvider>().fetch(preferences);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          if (provider.hasSearched)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Refine search',
              onPressed: () => context.read<RecommendationProvider>().reset(),
            ),
        ],
      ),
      body: provider.hasSearched ? _buildResults(provider) : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MatchingBanner(),
          const SizedBox(height: 20),
          const _StepsExplainer(),
          const SizedBox(height: 28),
          _SectionHeader(
            icon: Icons.menu_book_outlined,
            title: 'Which subjects do you need help with?',
          ),
          const SizedBox(height: 4),
          const Text(
            'Select all that apply — the more you choose, the better we match',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _subjects.map((subject) {
              final selected = _selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selectedSubjects.add(subject);
                  } else {
                    _selectedSubjects.remove(subject);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.school_outlined,
            title: 'What is your current level?',
          ),
          const SizedBox(height: 12),
          ..._levels.map(
            (entry) => _SelectableRow(
              label: entry.$1,
              selected: _level == entry.$2,
              onTap: () =>
                  setState(() => _level = _level == entry.$2 ? null : entry.$2),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(icon: Icons.tune, title: 'Preferred mode'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _modes
                .map(
                  (m) => ChoiceChip(
                    label: Text(m),
                    selected: _mode == m,
                    onSelected: (_) => setState(() => _mode = m),
                  ),
                )
                .toList(),
          ),
          if (_mode != 'Online') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Budget (Rs./month)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goal,
            decoration: const InputDecoration(
              labelText: 'Your goal (optional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.calendar_today_outlined,
            title: 'Available days',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _days.map((day) {
              final selected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Find Matches',
            isLoading: context.watch<RecommendationProvider>().isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(RecommendationProvider provider) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.errorMessage != null) {
      return ErrorView(message: provider.errorMessage!, onRetry: _submit);
    }
    if (provider.results.isEmpty) {
      return const Center(
        child: Text('No matches found. Try refining your search.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _RecommendationCard(course: provider.results[index]),
    );
  }
}

/// Dark-to-accent gradient banner introducing the AI matching flow, echoing
/// the "AI-Powered Tutor Matching" panel from the reference web dashboard.
class _MatchingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.mintDark, AppColors.mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Powered Tutor Matching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tell us what you need and our matching engine scores every course against your subjects, budget, and schedule to find your best fit.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                    height: 1.4,
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

class _StepsExplainer extends StatelessWidget {
  const _StepsExplainer();

  static const _steps = [
    (
      Icons.checklist_rtl,
      'Pick your subjects',
      'Tell us what you struggle with',
    ),
    (Icons.tune, 'Set preferences', 'Budget, mode, and days'),
    (Icons.auto_awesome, 'Get matched', 'AI scores every course for you'),
    (Icons.flash_on_outlined, 'Enroll instantly', 'One tap to join the class'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: _steps
          .map(
            (step) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(step.$1, size: 20, color: AppColors.mintDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        step.$3,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mintDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintLight : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.mint : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? AppColors.mintDark : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.course});

  final RecommendedCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(courseId: course.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _MatchScorePill(score: course.matchScore),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  AvatarImage(
                    imageUrl: course.tutor.profilePicture,
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${course.tutor.name} • ${course.subject}'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.mintDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course.aiInsight,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  course.feeDisplay,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mintDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchScorePill extends StatelessWidget {
  const _MatchScorePill({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score% match',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.peachDark,
        ),
      ),
    );
  }
}
