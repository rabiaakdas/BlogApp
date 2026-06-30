import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/snackbar_helper.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _bodyController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;

  @override
  void dispose() {
    _bodyController.dispose();
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

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submit() async {
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      showErrorSnackBar(context, 'Gönderi içeriği boş olamaz');
      return;
    }

    final postProvider = context.read<PostProvider>();
    final success = await postProvider.createPost(
      body: body,
      image: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      showErrorSnackBar(context, 'Gönderi paylaşılamadı');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PostProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Gönderi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SectionCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Gönderi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Fikrini yaz, istersen bir görselle güçlendir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _bodyController,
                  label: 'Bugün ne paylaşmak istersin?',
                  icon: Icons.notes_outlined,
                  minLines: 6,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _selectedImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: isLoading ? null : _removeImage,
                      icon: const Icon(Icons.close),
                      label: const Text('Seçilen görseli kaldır'),
                    ),
                  ),
                ] else
                  _ImagePickerBox(onPressed: isLoading ? null : _pickImage),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Paylaş',
                  icon: Icons.send_outlined,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  const _ImagePickerBox({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE3F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              'Görsel Seç',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
