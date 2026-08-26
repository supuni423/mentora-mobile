import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recommendation.dart';
import '../../providers/recommendation_provider.dart';
import '../../theme/app_theme.dart';
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
const _levels = ['A/L', 'O/L', 'Grade 1-5', 'University'];
const _modes = ['Online', 'Physical', 'Both'];

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _subjects = TextEditingController();
  final _budget = TextEditingController();
  final _goal = TextEditingController();
  final _city = TextEditingController();
  String? _level;
  String _mode = 'Both';
  final Set<String> _selectedDays = {};

  @override
  void dispose() {
    _subjects.dispose();
    _budget.dispose();
    _goal.dispose();
    _city.dispose();
    super.dispose();
  }

  void _submit() {
    final preferences = RecommendationPreferences(
      subjects: _subjects.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
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
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppColors.mintDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tell us what you\'re looking for and our AI will match you with the best courses.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _subjects,
            decoration: const InputDecoration(
              labelText: 'Subjects (comma separated)',
              hintText: 'e.g. Mathematics, ICT',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: const InputDecoration(labelText: 'Level'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any')),
              ..._levels.map((l) => DropdownMenuItem(value: l, child: Text(l))),
            ],
            onChanged: (v) => setState(() => _level = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _mode,
            decoration: const InputDecoration(labelText: 'Preferred mode'),
            items: _modes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _mode = v ?? _mode),
          ),
          if (_mode != 'Online') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
          ],
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          Text('Available days', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
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
              const SizedBox(height: 4),
              Text('by ${course.tutor.name} • ${course.subject}'),
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
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${course.rating.toStringAsFixed(1)} (${course.reviews})',
                  ),
                  const Spacer(),
                  Text(
                    course.feeDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mintDark,
                    ),
                  ),
                ],
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
