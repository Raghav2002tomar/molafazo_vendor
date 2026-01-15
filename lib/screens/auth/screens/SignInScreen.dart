// lib/auth/sign_in_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'SignUpScreens.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    // Simple and readable email regex; adjust if needed
    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim());
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Here you would call your login API and check credentials
      final success = true; // Replace with actual API response

      if (success) {
        // Navigate to dashboard and remove all previous routes
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard', // Your dashboard route
                (route) => false,
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'Invalid email or password');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Login failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Logo / Wordmark placeholder
                    Text(
                      'ojà',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16,),
                    Text(
                      'Experience business slaes on another level with ọjà, your market friendly app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 100),
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    AppTextField(
                      controller: _emailCtrl,
                      labelText: 'Email',
                      hintText: 'raidenLord@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),

                    PasswordTextField(
                      controller: _passwordCtrl,
                      labelText: 'Password',
                      validator: _validatePassword,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          // TODO: navigate to Forgot Password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Log In'),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Don’t have an account? ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: navigate to Sign Up
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneSignupWizard()));
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

/// Reusable themed text field that behaves like TextFormField but keeps
/// spacing and style consistent with the app InputDecorationTheme.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Uses InputDecorationTheme from AppTheme; no hardcoded colors.
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show' : 'Hide',
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
