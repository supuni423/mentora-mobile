import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';
import 'enrollment_detail_screen.dart';

// Requested first (not the more intuitive-sounding "Pending") — the
// backend creates new enrollments with status 'requested'.
const _tabs = EnrollmentStatus.all;

class MyEnrollmentsScreen extends StatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Enrollments'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs
                .map((s) => Tab(text: EnrollmentStatus.label(s)))
                .toList(),
          ),
        ),
        body: Consumer<EnrollmentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.enrollments.isEmpty) {
              return const LoadingIndicator();
            }
            if (provider.errorMessage != null && provider.enrollments.isEmpty) {
              return ErrorView(
                message: provider.errorMessage!,
                onRetry: provider.load,
              );
            }
            return TabBarView(
              children: _tabs.map((status) {
                final filtered = provider.enrollments
                    .where((e) => e.status == status)
                    .toList();
                if (filtered.isEmpty) {
                  return Center(child: Text('No $status enrollments.'));
                }
                return RefreshIndicator(
                  onRefresh: provider.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final enrollment = filtered[index];
                      return Card(
                        child: ListTile(
                          title: Text(enrollment.title ?? 'Course'),
                          subtitle: Text(
                            '${enrollment.selectedDay} • ${enrollment.selectedTime}',
                          ),
                          trailing: StatusBadge(status: enrollment.status),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EnrollmentDetailScreen(
                                enrollmentId: enrollment.id,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
