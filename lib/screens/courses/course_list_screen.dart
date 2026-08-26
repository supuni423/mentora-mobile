import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import 'course_detail_screen.dart';
import 'course_filter_sheet.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CourseProvider>();
      if (provider.courses.isEmpty) provider.loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CourseProvider>().loadNextPage();
    }
  }

  Future<void> _openFilters() async {
    final provider = context.read<CourseProvider>();
    final result = await showCourseFilterSheet(
      context,
      current: CourseFilterResult(
        subject: provider.subject,
        mode: provider.mode,
        location: provider.location,
        minRating: provider.minRating,
        maxFee: provider.maxFee,
        sortBy: provider.sortBy,
      ),
    );
    if (result != null) {
      provider.applyFilters(
        subject: result.subject,
        mode: result.mode,
        location: result.location,
        minRating: result.minRating,
        maxFee: result.maxFee,
        sortBy: result.sortBy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search courses',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) =>
                  context.read<CourseProvider>().search(value.trim()),
            ),
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CourseProvider provider) {
    if (provider.isLoading && provider.courses.isEmpty) {
      return const LoadingIndicator();
    }
    if (provider.errorMessage != null && provider.courses.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.loadFirstPage(),
      );
    }
    if (provider.courses.isEmpty) {
      return const Center(child: Text('No courses found.'));
    }
    return RefreshIndicator(
      onRefresh: provider.loadFirstPage,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.courses.length + (provider.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= provider.courses.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final course = provider.courses[index];
          return CourseCard(
            course: course,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CourseDetailScreen(courseId: course.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
