import 'package:flutter/material.dart';

class CourseFilterResult {
  const CourseFilterResult({
    this.subject,
    this.mode,
    this.location,
    this.minRating,
    this.maxFee,
    this.sortBy,
  });

  final String? subject;
  final String? mode;
  final String? location;
  final double? minRating;
  final double? maxFee;
  final String? sortBy;
}

const _modes = ['online', 'physical'];
const _sortOptions = {
  'rating': 'Top rated',
  'price_low': 'Price: low to high',
  'price_high': 'Price: high to low',
};

Future<CourseFilterResult?> showCourseFilterSheet(
  BuildContext context, {
  required CourseFilterResult current,
}) {
  return showModalBottomSheet<CourseFilterResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CourseFilterSheet(current: current),
  );
}

class _CourseFilterSheet extends StatefulWidget {
  const _CourseFilterSheet({required this.current});

  final CourseFilterResult current;

  @override
  State<_CourseFilterSheet> createState() => _CourseFilterSheetState();
}

class _CourseFilterSheetState extends State<_CourseFilterSheet> {
  late final _subject = TextEditingController(
    text: widget.current.subject ?? '',
  );
  late final _location = TextEditingController(
    text: widget.current.location ?? '',
  );
  late final _maxFee = TextEditingController(
    text: widget.current.maxFee != null
        ? widget.current.maxFee!.toStringAsFixed(0)
        : '',
  );
  String? _mode;
  double? _minRating;
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    _mode = widget.current.mode;
    _minRating = widget.current.minRating;
    _sortBy = widget.current.sortBy;
  }

  @override
  void dispose() {
    _subject.dispose();
    _location.dispose();
    _maxFee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _subject,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              decoration: const InputDecoration(labelText: 'Mode'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                ..._modes.map(
                  (m) => DropdownMenuItem(value: m, child: Text(m)),
                ),
              ],
              onChanged: (v) => setState(() => _mode = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxFee,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max fee (Rs.)'),
            ),
            const SizedBox(height: 12),
            Text('Minimum rating: ${_minRating?.toStringAsFixed(1) ?? 'Any'}'),
            Slider(
              value: _minRating ?? 0,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating?.toStringAsFixed(1) ?? 'Any',
              onChanged: (v) => setState(() => _minRating = v == 0 ? null : v),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Default')),
                ..._sortOptions.entries.map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                ),
              ],
              onChanged: (v) => setState(() => _sortBy = v),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const CourseFilterResult()),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final maxFee = double.tryParse(_maxFee.text.trim());
                      Navigator.of(context).pop(
                        CourseFilterResult(
                          subject: _subject.text.trim().isEmpty
                              ? null
                              : _subject.text.trim(),
                          mode: _mode,
                          location: _location.text.trim().isEmpty
                              ? null
                              : _location.text.trim(),
                          minRating: _minRating,
                          maxFee: maxFee,
                          sortBy: _sortBy,
                        ),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
