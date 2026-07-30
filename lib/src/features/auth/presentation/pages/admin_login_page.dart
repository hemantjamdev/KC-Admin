import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/double_back_to_exit_wrapper.dart';
import '../controllers/admin_auth_controller.dart';

/// Admin Login Page using Firebase Auth Email/Password.
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late final AdminAuthController _authController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authController = AdminAuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _authController.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.adminHome);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            _authController.authError ??
            'Login failed. Please verify credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header Section
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'KAPADA CREATION',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.adminBadgeBackground,
                              borderRadius: AppRadius.borderPill,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Text(
                              'ADMIN PORTAL',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Login Card Container
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(color: AppColors.surfaceBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sign in with your administrative credentials to continue.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIcons.warningCircle(),
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Email Input
                            AppTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email Address',
                              hintText: 'Enter email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode),
                              prefixIcon: PhosphorIcon(
                                PhosphorIcons.envelope(),
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Password Input
                            AppTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: 'Password',
                              hintText: 'Enter password',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              prefixIcon: PhosphorIcon(
                                PhosphorIcons.lock(),
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              suffixIcon: IconButton(
                                icon: PhosphorIcon(
                                  _obscurePassword
                                      ? PhosphorIcons.eyeSlash()
                                      : PhosphorIcons.eye(),
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Login Submit Button
                            AppButton(
                              text: 'Sign In',
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleLogin,
                              icon: PhosphorIcons.arrowRight(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Compact Footer Text
                    const Center(
                      child: Text(
                        'Authorized staff access only',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
