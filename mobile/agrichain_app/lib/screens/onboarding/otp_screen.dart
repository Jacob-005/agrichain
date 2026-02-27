import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/app_strings.dart';
import '../../app/theme.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final lang = ref.read(userStateProvider).language;
    if (phone.length != 10) {
      _showSnackBar(t('valid_10_digit', lang), isError: true);
      return;
    }

    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    final result = await api.sendOtp(phone);

    setState(() => _loading = false);

    if (result.success) {
      setState(() => _otpSent = true);
      _showSnackBar('✅ ${t('otp_sent', lang)} +91 $phone');
      // Focus first OTP box
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _otpFocusNodes[0].requestFocus();
      });
    } else {
      _showSnackBar(t('failed_send_otp', lang), isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    final lang = ref.read(userStateProvider).language;
    if (otp.length != 6) {
      _showSnackBar(t('enter_all_6', lang), isError: true);
      return;
    }

    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    final phone = _phoneController.text.trim();
    final result = await api.verifyOtp(phone, otp);

    setState(() => _loading = false);

    if (result.success) {
      final token = result.data?['token'] ?? '';
      ref.read(userStateProvider.notifier).setToken(token);
      ref.read(userStateProvider.notifier).setProfile(name: '', phone: phone);

      final storage = ref.read(storageServiceProvider);
      await storage.saveToken(token);

      if (mounted) context.go('/personal-info');
    } else {
      _showSnackBar(t('invalid_otp', lang), isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        backgroundColor: isError
            ? AgriChainTheme.dangerRed
            : AgriChainTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(userStateProvider).language;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // ── Back button ──
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AgriChainTheme.darkText,
                ),
                onPressed: () => context.go('/language'),
              ),
              const SizedBox(height: 16),

              // ── Header ──
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AgriChainTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 28,
                  color: AgriChainTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _otpSent ? t('enter_otp', lang) : t('enter_mobile', lang),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _otpSent
                    ? '${t('otp_sent', lang)} +91 ${_phoneController.text}'
                    : t('otp_subtitle', lang),
                style: const TextStyle(
                  fontSize: 16,
                  color: AgriChainTheme.greyText,
                ),
              ),
              const SizedBox(height: 32),

              // ── Phone input (always visible) ──
              TextField(
                controller: _phoneController,
                enabled: !_otpSent,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: t('enter_10_digit', lang),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇮🇳', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 6),
                        Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AgriChainTheme.darkText,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          height: 28,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  filled: true,
                  fillColor: _otpSent ? const Color(0xFFF5F5F5) : Colors.white,
                ),
              ),

              if (!_otpSent) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _sendOtp,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      t('send_otp', lang),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],

              // ── OTP section ──
              if (_otpSent) ...[
                const SizedBox(height: 32),
                // 6-box OTP input
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AgriChainTheme.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 5) {
                                _otpFocusNodes[i + 1].requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                _otpFocusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 12),
                // Demo hint
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AgriChainTheme.cautionYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFE65100),
                      ),
                      SizedBox(width: 6),
                      Text(
                        t('demo_otp', lang),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _verifyOtp,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_user),
                    label: Text(
                      t('verify_otp', lang),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      for (final c in _otpControllers) {
                        c.clear();
                      }
                      setState(() => _otpSent = false);
                    },
                    child: Text(
                      t('change_number', lang),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
