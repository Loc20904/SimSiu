import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_logo.dart';

enum _AuthMode { login, register }

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);
    var completed = false;

    try {
      if (_mode == _AuthMode.login) {
        await AuthService.instance.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.instance.register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );
      }

      completed = true;
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted && !completed) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _changeMode(Set<_AuthMode> selected) {
    if (selected.isEmpty || selected.first == _mode) {
      return;
    }

    setState(() {
      _mode = selected.first;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _mode == _AuthMode.register;
    final title = isRegister ? 'Tạo tài khoản' : 'Chào mừng trở lại';
    final subtitle = isRegister
        ? 'Nhập thông tin cơ bản để bắt đầu đặt mua sim.'
        : 'Đăng nhập để xem sim, đặt mua và theo dõi đơn hàng.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppLogo(size: 46),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SegmentedButton<_AuthMode>(
                              segments: const [
                                ButtonSegment(
                                  value: _AuthMode.login,
                                  icon: Icon(Icons.login),
                                  label: Text('Đăng nhập'),
                                ),
                                ButtonSegment(
                                  value: _AuthMode.register,
                                  icon: Icon(Icons.person_add_alt_1),
                                  label: Text('Đăng ký'),
                                ),
                              ],
                              selected: {_mode},
                              onSelectionChanged: _isSubmitting
                                  ? null
                                  : _changeMode,
                              showSelectedIcon: false,
                            ),
                            const SizedBox(height: 18),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: isRegister
                                  ? _RegisterFields(
                                      key: const ValueKey('register-fields'),
                                      fullNameController: _fullNameController,
                                      phoneController: _phoneController,
                                      requiredValidator: _requiredValidator,
                                      phoneValidator: _phoneValidator,
                                    )
                                  : const SizedBox(
                                      key: ValueKey('login-fields'),
                                    ),
                            ),
                            TextFormField(
                              key: const ValueKey('email_field'),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: _emailValidator,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const ValueKey('password_field'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Hiện mật khẩu'
                                      : 'Ẩn mật khẩu',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: _passwordValidator,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              key: const ValueKey('auth_submit_button'),
                              onPressed: _isSubmitting ? null : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      isRegister
                                          ? Icons.person_add_alt_1
                                          : Icons.login,
                                    ),
                              label: Text(
                                _isSubmitting
                                    ? 'Đang xử lý'
                                    : isRegister
                                    ? 'Tạo tài khoản'
                                    : 'Đăng nhập',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final message = _requiredValidator(value, 'email');
    if (message != null) {
      return message;
    }

    final email = value!.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) {
      return 'Email không hợp lệ.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final message = _requiredValidator(value, 'số điện thoại');
    if (message != null) {
      return message;
    }

    final phone = value!.trim();
    final valid = RegExp(r'^[0-9]{9,11}$').hasMatch(phone);
    if (!valid) {
      return 'Số điện thoại cần 9-11 chữ số.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final message = _requiredValidator(value, 'mật khẩu');
    if (message != null) {
      return message;
    }

    if (value!.length < 6) {
      return 'Mật khẩu cần tối thiểu 6 ký tự.';
    }
    return null;
  }
}

class _RegisterFields extends StatelessWidget {
  const _RegisterFields({
    super.key,
    required this.fullNameController,
    required this.phoneController,
    required this.requiredValidator,
    required this.phoneValidator,
  });

  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final String? Function(String? value, String fieldName) requiredValidator;
  final String? Function(String? value) phoneValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          key: const ValueKey('full_name_field'),
          controller: fullNameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            labelText: 'Họ tên',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (value) => requiredValidator(value, 'họ tên'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('phone_field'),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: phoneValidator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
