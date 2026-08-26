import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';
import 'enrollment_form_screen.dart';

class EnrollmentDetailScreen extends StatefulWidget {
  const EnrollmentDetailScreen({super.key, required this.enrollmentId});

  final int enrollmentId;

  @override
  State<EnrollmentDetailScreen> createState() => _EnrollmentDetailScreenState();
}

class _EnrollmentDetailScreenState extends State<EnrollmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentProvider>().loadDetail(widget.enrollmentId);
    });
  }

  Future<void> _cancel(BuildContext context, Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel enrollment'),
        content: const Text('Are you sure you want to cancel this enrollment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final provider = context.read<EnrollmentProvider>();
    final ok = await provider.cancel(enrollment.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Could not cancel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnrollmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Enrollment')),
      body: provider.isDetailLoading
          ? const LoadingIndicator()
          : provider.detailError != null
          ? ErrorView(
              message: provider.detailError!,
              onRetry: () => context.read<EnrollmentProvider>().loadDetail(
                widget.enrollmentId,
              ),
            )
          : provider.selected == null
          ? const SizedBox.shrink()
          : _DetailBody(
              enrollment: provider.selected!,
              onCancel: () => _cancel(context, provider.selected!),
            ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.enrollment, required this.onCancel});

  final Enrollment enrollment;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final canEdit = enrollment.status == EnrollmentStatus.requested;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                enrollment.title ?? 'Course',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            StatusBadge(status: enrollment.status),
          ],
        ),
        const SizedBox(height: 4),
        if (enrollment.tutorName != null)
          Text('Tutor: ${enrollment.tutorName}'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Day', enrollment.selectedDay),
                _row('Time', enrollment.selectedTime),
                _row('Mode', enrollment.preferredMode),
                _row('Message', enrollment.message ?? '-'),
                _row('Submitted by', enrollment.fullName),
                _row('Sessions attended', '${enrollment.sessionsAttended}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (canEdit)
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EnrollmentFormScreen(
                  classId: enrollment.classId,
                  courseTitle: enrollment.title ?? '',
                  courseMode: enrollment.mode,
                  schedule: enrollment.schedule,
                  existingEnrollment: enrollment,
                ),
              ),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Request'),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          label: const Text(
            'Cancel Enrollment',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
