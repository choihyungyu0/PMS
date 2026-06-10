import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.controller,
    required this.initialSignupMode,
    required this.onBackToOnboarding,
  });

  final AuthController controller;
  final bool initialSignupMode;
  final VoidCallback onBackToOnboarding;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  DateTime? _birthDate;
  late bool _signupMode;

  @override
  void initState() {
    super.initState();
    _signupMode = widget.initialSignupMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToOnboarding,
        ),
        title: Text(_signupMode ? '회원가입' : '로그인'),
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
                          _signupMode ? '모어 사이클 시작하기' : '다시 만나서 반가워요',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          key: const Key('emailField'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: '이메일'),
                          validator: (value) =>
                              value != null && value.contains('@')
                              ? null
                              : '이메일을 입력해주세요.',
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
                            if (_signupMode && value.length < 8) {
                              return '비밀번호는 8자 이상이어야 해요.';
                            }
                            return null;
                          },
                        ),
                        if (_signupMode) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('nicknameField'),
                            controller: _nicknameController,
                            decoration: const InputDecoration(labelText: '닉네임'),
                            validator: (value) => value == null || value.isEmpty
                                ? '닉네임을 입력해주세요.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickBirthDate,
                            icon: const Icon(Icons.cake_outlined),
                            label: Text(
                              _birthDate == null
                                  ? '생년월일 선택'
                                  : AppDateUtils.date(_birthDate!),
                            ),
                          ),
                        ],
                        if (widget.controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.controller.errorMessage!,
                            style: const TextStyle(color: Color(0xFFC44949)),
                          ),
                        ],
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: _signupMode ? '회원가입' : '로그인',
                          loading: widget.controller.loading,
                          onPressed: _submit,
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _signupMode = !_signupMode),
                          child: Text(
                            _signupMode ? '이미 계정이 있어요' : '처음이라면 회원가입하기',
                          ),
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

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final success = _signupMode
        ? await widget.controller.signup(
            _emailController.text.trim(),
            _passwordController.text,
            _nicknameController.text.trim(),
            _birthDate == null ? null : AppDateUtils.date(_birthDate!),
          )
        : await widget.controller.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_signupMode ? '회원가입이 완료되었어요.' : '로그인되었어요.'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }
  }
}
