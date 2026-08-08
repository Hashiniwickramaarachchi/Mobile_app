import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/input_field.dart';
import '../../widgets/reusable_button.dart';

class SignupCredentials {
  const SignupCredentials({
    required this.username,
    required this.email,
    required this.password,
  });
  final String username;
  final String email;
  final String password;
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onBackToLogin,
    required this.onSubmit,
  });
  final VoidCallback onBackToLogin;
  final ValueChanged<SignupCredentials> onSubmit;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.outlined(
                  onPressed: widget.onBackToLogin,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: 8),
              Text('Sign Up', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text(
                'Create an account',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              InputField(
                  controller: _username,
                  label: 'Username',
                  requiredField: true),
              const SizedBox(height: 10),
              InputField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true),
              const SizedBox(height: 10),
              InputField(
                  controller: _password,
                  label: 'Password',
                  obscureText: true,
                  requiredField: true),
              const SizedBox(height: 18),
              ReusableButton(label: 'Create Account', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final data = SignupCredentials(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );
    widget.onSubmit(data);
  }
}