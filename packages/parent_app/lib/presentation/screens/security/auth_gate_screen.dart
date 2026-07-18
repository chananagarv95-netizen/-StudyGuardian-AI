import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/theme/app_colors.dart';

import '../../core/di/providers.dart';

/// A reusable authentication gate that requires PIN or biometric
/// verification before allowing access to sensitive actions.
///
/// Push this screen and await its result:
/// ```dart
/// final authenticated = await Navigator.push<bool>(
///   context,
///   MaterialPageRoute(builder: (_) => const AuthGateScreen()),
/// );
/// ```
class AuthGateScreen extends ConsumerStatefulWidget {
  /// Optional title shown above the PIN entry.
  final String title;

  const AuthGateScreen({
    super.key,
    this.title = 'Enter Parent PIN',
  });

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;
  bool _isAuthenticating = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    // Try biometric first
    _attemptBiometric();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attemptBiometric() async {
    final securityService = ref.read(securityServiceProvider);
    if (!securityService.isBiometricEnabled) return;

    setState(() => _isAuthenticating = true);
    final success = await securityService.authenticate();
    setState(() => _isAuthenticating = false);

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _verifyPin() {
    final securityService = ref.read(securityServiceProvider);
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() => _errorText = 'Please enter your PIN');
      return;
    }

    if (securityService.verifyPin(pin)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorText = 'Incorrect PIN';
        _pinController.clear();
      });
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Authentication required for this action',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 40),

              // PIN field with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.value > 0.5) ? -1 : 1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 12,
                    ),
                    errorText: _errorText,
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
                  onSubmitted: (_) => _verifyPin(),
                ),
              ),
              const SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isAuthenticating ? null : _verifyPin,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biometric button
              if (ref.watch(securityServiceProvider).isBiometricEnabled)
                TextButton.icon(
                  onPressed: _isAuthenticating ? null : _attemptBiometric,
                  icon: const Icon(Icons.fingerprint, color: Color(0xFF10B981)),
                  label: Text(
                    _isAuthenticating ? 'Authenticating...' : 'Use Biometric',
                    style: const TextStyle(color: Color(0xFF10B981)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
