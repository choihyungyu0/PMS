import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../state/auth_controller.dart';

class SignupBasicInfoScreen extends StatefulWidget {
  const SignupBasicInfoScreen({
    super.key,
    required this.controller,
    required this.onBackToWelcome,
    required this.onCloseToWelcome,
    required this.onLogin,
  });

  final AuthController controller;
  final VoidCallback onBackToWelcome;
  final VoidCallback onCloseToWelcome;
  final VoidCallback onLogin;

  @override
  State<SignupBasicInfoScreen> createState() => _SignupBasicInfoScreenState();
}

class _SignupBasicInfoScreenState extends State<SignupBasicInfoScreen> {
  static const _borderColor = Color(0xFFD6D2E6);
  static const _labelColor = Color(0xFF484852);
  static const _errorColor = Color(0xFFC44949);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _birthDate;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = (constraints.maxWidth * 0.1)
                  .clamp(32.0, 48.0)
                  .toDouble();
              final topGap = (constraints.maxHeight * 0.034)
                  .clamp(22.0, 36.0)
                  .toDouble();
              final fieldGap = (constraints.maxHeight * 0.034)
                  .clamp(24.0, 30.0)
                  .toDouble();

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (context, _) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: topGap),
                              SizedBox(
                                height: 48,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _TopIconButton(
                                        semanticLabel: '이전 화면',
                                        icon: Icons.arrow_back_ios_new_rounded,
                                        onTap: _handleBack,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: _TopIconButton(
                                        semanticLabel: '회원가입 닫기',
                                        icon: Icons.close_rounded,
                                        onTap: widget.onCloseToWelcome,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 34),
                              const Text(
                                '회원가입',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                '더 정확한 맞춤 케어를 위해\n기본 정보를 입력해주세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF46464D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                  height: 1.62,
                                ),
                              ),
                              const SizedBox(height: 66),
                              _SignupInputField(
                                key: const Key('signupNameField'),
                                label: '이름',
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '이름을 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldGap),
                              _SignupInputField(
                                key: const Key('signupBirthDateField'),
                                label: '생년월일',
                                controller: _birthDateController,
                                readOnly: true,
                                onTap: _pickBirthDate,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '생년월일을 선택해주세요.';
                                  }
                                  if (_birthDate == null) {
                                    return '올바른 생년월일을 선택해주세요.';
                                  }
                                  if (_birthDate!.isAfter(DateTime.now())) {
                                    return '미래 날짜는 선택할 수 없어요.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldGap),
                              _SignupInputField(
                                key: const Key('signupEmailField'),
                                label: '이메일',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  final valid = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email);
                                  if (!valid) {
                                    return '올바른 이메일을 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldGap),
                              _SignupInputField(
                                key: const Key('signupPasswordField'),
                                label: '비밀번호',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? '비밀번호 보기'
                                      : '비밀번호 숨기기',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                validator: (value) {
                                  final password = value ?? '';
                                  if (password.length < 8) {
                                    return '비밀번호는 8자 이상 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                              if (widget.controller.errorMessage != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  widget.controller.errorMessage!.isEmpty
                                      ? '회원가입에 실패했어요. 입력 정보를 확인해주세요.'
                                      : widget.controller.errorMessage!,
                                  key: const Key('signupErrorMessage'),
                                  style: const TextStyle(
                                    color: _errorColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 50),
                              _GradientButton(
                                key: const Key('signupNextButton'),
                                label: '다음',
                                loading: widget.controller.loading,
                                onTap: _submit,
                              ),
                              const SizedBox(height: 42),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    '이미 계정이 있으신가요? ',
                                    style: TextStyle(
                                      color: Color(0xFF46464D),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  GestureDetector(
                                    key: const Key('signupLoginLink'),
                                    onTap: widget.onLogin,
                                    child: const Text(
                                      '로그인',
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 34),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    widget.onBackToWelcome();
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '생년월일 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _birthDate = picked;
      _birthDateController.text = AppDateUtils.date(picked);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final success = await widget.controller.signup(
      _emailController.text.trim().toLowerCase(),
      _passwordController.text,
      _nameController.text.trim(),
      _birthDate == null ? null : AppDateUtils.date(_birthDate!),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었어요.'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.black, size: 32),
          ),
        ),
      ),
    );
  }
}

class _SignupInputField extends StatelessWidget {
  const _SignupInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _SignupBasicInfoScreenState._labelColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            height: 1,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          cursorColor: AppColors.primaryPurple,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(minHeight: 58),
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _SignupBasicInfoScreenState._borderColor,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _SignupBasicInfoScreenState._errorColor,
                width: 1.3,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _SignupBasicInfoScreenState._errorColor,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              color: _SignupBasicInfoScreenState._errorColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              height: 1.25,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF6D32F2),
                  AppColors.primaryPurple,
                  Color(0xFF7336F2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
