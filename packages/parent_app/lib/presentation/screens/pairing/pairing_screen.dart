import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/models/family_model.dart';
import 'package:shared/services/firestore_service.dart';
import '../../../core/di/providers.dart';

/// Device pairing screen with QR code and manual code display.
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  String? _pairingCode;
  String? _familyId;
  bool _isLoading = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _createFamily();
  }

  Future<void> _createFamily() async {
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;

      final firestoreService = ref.read(firestoreServiceProvider);
      final code = _generateCode();
      final familyId = const Uuid().v4();

      final family = FamilyModel(
        id: familyId,
        name: '${user.displayName ?? 'My'} Family',
        pairingCode: code,
        createdAt: DateTime.now(),
        parentIds: [user.uid],
        childIds: [],
        primaryParentId: user.uid,
      );
      await firestoreService.createFamily(family);

      setState(() {
        _pairingCode = code;
        _familyId = familyId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create family: $e')),
        );
      }
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().microsecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rng + i * 7) % chars.length]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Device'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Scan this QR code on the child device',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  // QR Code Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: QrImageView(
                                data: _pairingCode ?? '',
                                version: QrVersions.auto,
                                size: 200,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('Or enter this code manually',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                if (_pairingCode != null) {
                                  Clipboard.setData(ClipboardData(text: _pairingCode!));
                                  setState(() => _copied = true);
                                  Future.delayed(const Duration(seconds: 2),
                                      () { if (mounted) setState(() => _copied = false); });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _pairingCode ?? '',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 8,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(_copied ? Icons.check : Icons.copy,
                                        color: const Color(0xFF6366F1), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue to Dashboard'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
