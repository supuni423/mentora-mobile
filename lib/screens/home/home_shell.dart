import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_gate.dart';
import '../courses/course_list_screen.dart';
import '../enrollments/my_enrollments_screen.dart';
import '../profile/profile_screen.dart';
import '../recommendations/recommendation_screen.dart';

/// Bottom-nav shell: Courses is always open (public browsing), the other
/// tabs show AuthGate when the student isn't logged in.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    final tabs = [
      const CourseListScreen(),
      const RecommendationScreen(),
      isAuthenticated
          ? const MyEnrollmentsScreen()
          : const AuthGate(message: 'Log in to see your enrollments'),
      isAuthenticated
          ? const ProfileScreen()
          : const AuthGate(message: 'Log in to view your profile'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'For You',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            label: 'Enrollments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
