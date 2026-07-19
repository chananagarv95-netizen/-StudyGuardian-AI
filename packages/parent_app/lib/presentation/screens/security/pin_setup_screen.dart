import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/theme/app_colors.dart';

import '../../../core/di/providers.dart';

/// Screen for setting or changing the parent PIN.
///
/// Requires entering the PIN twice for confirmation. If a PIN already exists,
/// the user must verify the old PIN first.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();

  String? _error;
  bool _requireOldPin = false;

  @override
  void initState() {
    super.initState();
    final securityService = ref.read(securityServiceProvider);
    _requireOldPin = securityService.hasPin;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    _oldPinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final securityService = ref.read(securityServiceProvider);

    // Verify old PIN if changing
    if (_requireOldPin) {
      if (!securityService.verifyPin(_oldPinController.text.trim())) {
        setState(() => _error = 'Current PIN is incorrect');
        HapticFeedback.heavyImpact();
        return;
      }
    }

    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }

    if (pin != confirm) {
      setState(() => _error = 'PINs do not match');
      return;
    }

    await securityService.setPin(pin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent PIN set successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _requireOldPin ? 'Change PIN' : 'Set Parent PIN',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.pin_rounded,
                    size: 40,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _requireOldPin
                    ? 'Enter your current PIN, then set a new one.'
                    : 'Set a 4–6 digit PIN to protect sensitive settings.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              // Old PIN (if changing)
              if (_requireOldPin) ...[
                _buildPinField(
                  controller: _oldPinController,
                  label: 'Current PIN',
                ),
                const SizedBox(height: 20),
              ],

              _buildPinField(
                controller: _pinController,
                label: 'New PIN',
              ),
              const SizedBox(height: 20),

              _buildPinField(
                controller: _confirmController,
                label: 'Confirm PIN',
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _savePin,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _requireOldPin ? 'Change PIN' : 'Set PIN',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        letterSpacing: 10,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF6366F1),
            width: 2,
          ),
        ),
      ),
    );
  }
}
