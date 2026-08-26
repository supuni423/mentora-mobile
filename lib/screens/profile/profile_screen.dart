import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar_image.dart';
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
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.mint, AppColors.peach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AvatarImage(imageUrl: profile.profilePicture, radius: 46),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            profile.name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Center(
          child: Text(
            profile.email,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [
            _StatTile(
              icon: Icons.school_outlined,
              color: AppColors.mint,
              label: 'Enrolled',
              value: '${stats.classesEnrolled}',
            ),
            _StatTile(
              icon: Icons.play_circle_outline,
              color: AppColors.peach,
              label: 'Active',
              value: '${stats.activeClasses}',
            ),
            _StatTile(
              icon: Icons.hourglass_top_outlined,
              color: const Color(0xFFD9A441),
              label: 'Pending',
              value: '${stats.pendingApprovals}',
            ),
            _StatTile(
              icon: Icons.event_available_outlined,
              color: AppColors.mint,
              label: 'Sessions',
              value: '${stats.sessionsAttended}',
            ),
            _StatTile(
              icon: Icons.menu_book_outlined,
              color: AppColors.peach,
              label: 'Subjects',
              value: '${stats.subjectsStudying}',
            ),
            _StatTile(
              icon: Icons.star_outline,
              color: const Color(0xFFD9A441),
              label: 'Avg rating',
              value: stats.avgRatingGiven.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'School',
                  value: profile.school,
                ),
                _InfoRow(
                  icon: Icons.grade_outlined,
                  label: 'Grade',
                  value: profile.grade,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile.phone,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: profile.address,
                ),
                _InfoRow(
                  icon: Icons.info_outline,
                  label: 'Bio',
                  value: profile.bio,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.mintDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  hasValue ? value! : '-',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
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
