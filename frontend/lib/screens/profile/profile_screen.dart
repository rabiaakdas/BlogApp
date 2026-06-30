import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/avatar_view.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/snackbar_helper.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null || !mounted) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      showErrorSnackBar(context, 'İsim alanı boş olamaz');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: name,
      image: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedImage = null;
      });
      showSuccessSnackBar(context, 'Profil güncellendi');
    } else {
      showErrorSnackBar(
        context,
        authProvider.errorMessage ?? 'Profil güncellenemedi',
      );
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    context.read<PostProvider>().clear();
    context.read<CommentProvider>().clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(
                name: user?.name ?? '',
                email: user?.email ?? '',
                imageUrl: user?.image,
                selectedImage: _selectedImage,
                isLoading: authProvider.isLoading,
                onPickImage: _pickImage,
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : _clearSelectedImage,
                    icon: const Icon(Icons.close),
                    label: const Text('Seçilen görseli kaldır'),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SectionCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Profil bilgileri',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _nameController,
                      label: 'Ad Soyad',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      enabled: false,
                      initialValue: user?.email ?? '',
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Kaydet',
                      icon: Icons.save_outlined,
                      isLoading: authProvider.isLoading,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: authProvider.isLoading ? null : _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.selectedImage,
    required this.isLoading,
    required this.onPickImage,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final File? selectedImage;
  final bool isLoading;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (selectedImage != null)
                CircleAvatar(
                  radius: 58,
                  backgroundImage: FileImage(selectedImage!),
                )
              else
                AvatarView(name: name, imageUrl: imageUrl, radius: 58),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: isLoading ? null : onPickImage,
                  icon: const Icon(Icons.camera_alt_outlined),
                  tooltip: 'Görsel Seç',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}
