import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Kayıt olunamadı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 96,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthBrandHeader(
                      headline: 'Aramıza katıl',
                      subtitle:
                          'Düşüncelerini paylaş, insanlarla etkileşime geç.',
                    ),
                    const SizedBox(height: 20),
                    AuthFormCard(
                      children: [
                        Text(
                          'Kendi blog akışını bugün oluştur.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 18),
                        AuthTextField(
                          controller: _nameController,
                          label: 'Ad Soyad',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ad Soyad gerekli.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _emailController,
                          label: 'E-posta',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-posta gerekli.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passwordConfirmationController,
                          label: 'Şifre tekrar',
                          icon: Icons.verified_user_outlined,
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        AuthGradientButton(
                          label: 'Kayıt Ol',
                          isLoading: isLoading,
                          onPressed: _register,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AuthSwitchLink(
                      text: 'Zaten hesabın var mı?',
                      actionText: 'Giriş yap',
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
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
