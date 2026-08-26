import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This permanently deletes your account. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Could not delete account'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: provider.isLoading && provider.profile == null
          ? const LoadingIndicator()
          : provider.errorMessage != null && provider.profile == null
          ? ErrorView(
              message: provider.errorMessage!,
              onRetry: () => provider.load(),
            )
          : provider.profile == null
          ? const SizedBox.shrink()
          : _ProfileBody(onDeleteAccount: _confirmDeleteAccount),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.onDeleteAccount});

  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile!;
    final stats = profile.stats;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage: profile.profilePicture != null
                ? NetworkImage(profile.profilePicture!)
                : null,
            child: profile.profilePicture == null
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            profile.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Center(child: Text(profile.email)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _StatTile(label: 'Enrolled', value: '${stats.classesEnrolled}'),
            _StatTile(label: 'Active', value: '${stats.activeClasses}'),
            _StatTile(label: 'Pending', value: '${stats.pendingApprovals}'),
            _StatTile(label: 'Sessions', value: '${stats.sessionsAttended}'),
            _StatTile(label: 'Subjects', value: '${stats.subjectsStudying}'),
            _StatTile(
              label: 'Avg rating given',
              value: stats.avgRatingGiven.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'School', value: profile.school),
                _InfoRow(label: 'Grade', value: profile.grade),
                _InfoRow(label: 'Phone', value: profile.phone),
                _InfoRow(label: 'Address', value: profile.address),
                _InfoRow(label: 'Bio', value: profile.bio),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onDeleteAccount,
          child: const Text(
            'Delete account',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text((value == null || value!.isEmpty) ? '-' : value!),
          ),
        ],
      ),
    );
  }
}
