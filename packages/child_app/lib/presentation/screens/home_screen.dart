import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyProvider);
    final isForegroundRunning = ref.watch(foregroundServiceProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyGuardian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 100,
              color: Color(0xFF10B981), // Emerald
            ),
            const SizedBox(height: 24),
            const Text(
              'Monitoring Active',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your device is connected and protected by StudyGuardian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            // Family Status Card
            Card(
              elevation: 0,
              color: const Color(0xFF1E293B), // Slate 800
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    familyAsync.when(
                      data: (family) => _StatusRow(
                        icon: Icons.family_restroom,
                        title: 'Family Connection',
                        value: family != null ? 'Connected' : 'Not Connected',
                        isOk: family != null,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const _StatusRow(
                        icon: Icons.error,
                        title: 'Family Connection',
                        value: 'Error',
                        isOk: false,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    _StatusRow(
                      icon: Icons.sync,
                      title: 'Background Service',
                      value: isForegroundRunning ? 'Running' : 'Stopped',
                      isOk: isForegroundRunning,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isOk;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.isOk,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOk ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
