import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _isLoading = false;

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    try {
      // Refresh permission states
      await ref.refresh(usagePermissionProvider.future);
      await ref.refresh(batteryOptimizationProvider.future);
      
      final hasUsage = ref.read(usagePermissionProvider).valueOrNull ?? false;
      final hasBattery = ref.read(batteryOptimizationProvider).valueOrNull ?? false;

      if (hasUsage && hasBattery) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please grant all required permissions')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUsage = ref.watch(usagePermissionProvider).valueOrNull ?? false;
    final hasBattery = ref.watch(batteryOptimizationProvider).valueOrNull ?? false;
    final platformService = ref.read(platformChannelServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Required Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.security, size: 64, color: Color(0xFF6366F1)),
          const SizedBox(height: 24),
          const Text(
            'To keep your child safe, StudyGuardian needs the following permissions to function in the background.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          _PermissionTile(
            title: 'Usage Access',
            description: 'Allows tracking screen time and apps used.',
            isGranted: hasUsage,
            onTap: hasUsage ? null : () => platformService.requestUsagePermission(),
          ),
          const SizedBox(height: 16),
          
          _PermissionTile(
            title: 'Disable Battery Optimization',
            description: 'Prevents the system from killing the monitoring service.',
            isGranted: hasBattery,
            onTap: hasBattery ? null : () => platformService.requestDisableBatteryOptimization(),
          ),
          
          const SizedBox(height: 48),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _checkPermissions,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback? onTap;

  const _PermissionTile({
    required this.title,
    required this.description,
    required this.isGranted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isGranted ? Colors.green.withOpacity(0.1) : Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isGranted ? Colors.green : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          isGranted ? Icons.check_circle : Icons.error_outline,
          color: isGranted ? Colors.green : Colors.amber,
          size: 32,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isGranted
            ? null
            : TextButton(
                onPressed: onTap,
                child: const Text('GRANT'),
              ),
      ),
    );
  }
}
