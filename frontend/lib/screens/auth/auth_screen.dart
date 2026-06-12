import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.controller,
    required this.onBackToWelcome,
    required this.onSignupRequested,
  });

  final AuthController controller;
  final VoidCallback onBackToWelcome;
  final VoidCallback onSignupRequested;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToWelcome,
        ),
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '다시 만나서 반가워요',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          key: const Key('emailField'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(labelText: '이메일'),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return '이메일을 입력해주세요.';
                            }
                            final valid = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email);
                            if (!valid) {
                              return '올바른 이메일을 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('passwordField'),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: '비밀번호'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        if (widget.controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.controller.errorMessage!,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              color: Color(0xFFC44949),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: '로그인',
                          loading: widget.controller.loading,
                          onPressed: _submit,
                        ),
                        TextButton(
                          onPressed: widget.onSignupRequested,
                          child: const Text('처음이라면 회원가입하기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final success = await widget.controller.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인되었어요.'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }
  }
}
