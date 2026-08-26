import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

/// Shared by both booking a new course (create) and editing a still-pending
/// request (edit) — the backend's PUT requires the full field set anyway,
/// so the form always collects everything.
class EnrollmentFormScreen extends StatefulWidget {
  const EnrollmentFormScreen({
    super.key,
    required this.classId,
    required this.courseTitle,
    this.courseMode,
    required this.schedule,
    this.existingEnrollment,
  });

  final int classId;
  final String courseTitle;
  final String? courseMode;
  final Map<String, List<String>> schedule;
  final Enrollment? existingEnrollment;

  bool get isEdit => existingEnrollment != null;

  @override
  State<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<EnrollmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _school;
  late final TextEditingController _grade;
  late final TextEditingController _message;
  late String _preferredMode;
  String? _selectedDay;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEnrollment;
    final profile = context.read<ProfileProvider>().profile;
    final user = context.read<AuthProvider>().user;

    _fullName = TextEditingController(
      text: existing?.fullName ?? profile?.name ?? user?.fullName ?? '',
    );
    _email = TextEditingController(text: existing?.email ?? user?.email ?? '');
    _phone = TextEditingController(
      text: existing?.phone ?? profile?.phone ?? '',
    );
    _school = TextEditingController(
      text: existing?.school ?? profile?.school ?? '',
    );
    _grade = TextEditingController(
      text: existing?.grade ?? profile?.grade ?? '',
    );
    _message = TextEditingController(text: existing?.message ?? '');
    _preferredMode =
        existing?.preferredMode ??
        (widget.courseMode == 'both'
            ? 'online'
            : (widget.courseMode ?? 'online'));

    final days = widget.schedule.keys.toList();
    _selectedDay =
        existing?.selectedDay != null && days.contains(existing!.selectedDay)
        ? existing.selectedDay
        : (days.isNotEmpty ? days.first : null);
    final times = _selectedDay != null
        ? widget.schedule[_selectedDay] ?? const []
        : const <String>[];
    _selectedTime =
        existing?.selectedTime != null && times.contains(existing!.selectedTime)
        ? existing.selectedTime
        : (times.isNotEmpty ? times.first : null);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _school.dispose();
    _grade.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a day and time')),
      );
      return;
    }

    final provider = context.read<EnrollmentProvider>();
    final ok = widget.isEdit
        ? await provider.update(
            widget.existingEnrollment!.id,
            classId: widget.classId,
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            school: _school.text.trim(),
            grade: _grade.text.trim(),
            message: _message.text.trim(),
            preferredMode: _preferredMode,
            selectedDay: _selectedDay!,
            selectedTime: _selectedTime!,
          )
        : await provider.create(
            classId: widget.classId,
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            school: _school.text.trim(),
            grade: _grade.text.trim(),
            message: _message.text.trim(),
            preferredMode: _preferredMode,
            selectedDay: _selectedDay!,
            selectedTime: _selectedTime!,
          );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Enrollment updated'
                : 'Enrollment request submitted',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.submitError ?? 'Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<EnrollmentProvider>().isSubmitting;
    final days = widget.schedule.keys.toList();
    final times = _selectedDay != null
        ? widget.schedule[_selectedDay] ?? const <String>[]
        : const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Enrollment' : 'Enroll — ${widget.courseTitle}',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => Validators.required(v, label: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _school,
                  decoration: const InputDecoration(labelText: 'School'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _grade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                ),
                const SizedBox(height: 12),
                if (widget.courseMode == 'both')
                  DropdownButtonFormField<String>(
                    initialValue: _preferredMode,
                    decoration: const InputDecoration(
                      labelText: 'Preferred mode',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'online', child: Text('online')),
                      DropdownMenuItem(
                        value: 'physical',
                        child: Text('physical'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _preferredMode = v ?? _preferredMode),
                  ),
                if (days.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDay,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedDay = v;
                      final newTimes = v != null
                          ? widget.schedule[v] ?? const []
                          : const <String>[];
                      _selectedTime = newTimes.isNotEmpty
                          ? newTimes.first
                          : null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTime,
                    decoration: const InputDecoration(labelText: 'Time'),
                    items: times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTime = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _message,
                  decoration: const InputDecoration(
                    labelText: 'Message to tutor (optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: widget.isEdit ? 'Save Changes' : 'Submit Request',
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
