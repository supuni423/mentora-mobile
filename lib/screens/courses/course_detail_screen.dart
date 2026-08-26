import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../auth/login_screen.dart';
import '../enrollments/enrollment_form_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadDetail(widget.courseId);
    });
  }

  void _requireLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: Text(provider.selectedCourse?.title ?? 'Course')),
      body: provider.isDetailLoading
          ? const LoadingIndicator()
          : provider.detailError != null
          ? ErrorView(
              message: provider.detailError!,
              onRetry: () =>
                  context.read<CourseProvider>().loadDetail(widget.courseId),
            )
          : provider.selectedCourse == null
          ? const SizedBox.shrink()
          : _CourseDetailBody(
              provider: provider,
              isAuthenticated: isAuthenticated,
              onRequireLogin: _requireLogin,
            ),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  const _CourseDetailBody({
    required this.provider,
    required this.isAuthenticated,
    required this.onRequireLogin,
  });

  final CourseProvider provider;
  final bool isAuthenticated;
  final VoidCallback onRequireLogin;

  @override
  Widget build(BuildContext context) {
    final course = provider.selectedCourse!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: course.image != null
              ? Image.network(
                  course.image!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _bannerPlaceholder(),
                )
              : _bannerPlaceholder(),
        ),
        const SizedBox(height: 16),
        Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('by ${course.tutorName ?? 'Unknown tutor'}'),
        if (course.location != null) ...[
          const SizedBox(height: 4),
          Text(
            course.location!,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (course.subject.isNotEmpty) Chip(label: Text(course.subject)),
            if (course.mode != null) Chip(label: Text(course.mode!)),
            if (course.grade != null) Chip(label: Text(course.grade!)),
          ],
        ),
        const SizedBox(height: 16),
        if (course.description != null) ...[
          Text(
            'About this course',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(course.description!),
          const SizedBox(height: 16),
        ],
        if (course.whatYouLearn.isNotEmpty) ...[
          Text(
            'What you\'ll learn',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          ...course.whatYouLearn.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Fee: ${course.feeDisplay}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (!isAuthenticated) {
                onRequireLogin();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EnrollmentFormScreen(
                    classId: course.id,
                    courseTitle: course.title,
                    courseMode: course.mode,
                    schedule: course.schedule,
                  ),
                ),
              );
            },
            child: const Text('Enroll'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Reviews (${provider.reviews.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (provider.reviews.isEmpty) const Text('No reviews yet.'),
        ...provider.reviews.map(
          (review) => Card(
            child: ListTile(
              title: Text(review.studentName ?? 'Student'),
              subtitle: Text(review.comment ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.mintLight,
      child: const Icon(
        Icons.school_outlined,
        size: 48,
        color: AppColors.mintDark,
      ),
    );
  }
}
