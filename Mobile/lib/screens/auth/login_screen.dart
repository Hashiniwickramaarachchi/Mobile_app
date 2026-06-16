import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/input_field.dart';
import '../../widgets/reusable_button.dart';

class LoginCredentials {
  const LoginCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSignIn,
    required this.onOpenSignUp,
    this.successMessage = '',
    this.errorMessage = '',
  });

  final ValueChanged<LoginCredentials> onSignIn;
  final VoidCallback onOpenSignUp;
  final String successMessage;
  final String errorMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('SafeGuard',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('Welcome back',
                        style: TextStyle(color: AppColors.muted)),
                    if (widget.successMessage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.successMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF15803D)),
                        ),
                      ),
                    ],
                    if (widget.errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    InputField(
                        controller: _usernameController,
                        hint: 'Username',
                        requiredField: true),
                    const SizedBox(height: 10),
                    InputField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscureText: true,
                        requiredField: true),
                    const SizedBox(height: 18),
                    ReusableButton(label: 'Sign In', onPressed: _signIn),
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Do not have any account? '),
                        TextButton(
                          onPressed: widget.onOpenSignUp,
                          child: const Text('Sign up',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
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

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSignIn(
      LoginCredentials(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
