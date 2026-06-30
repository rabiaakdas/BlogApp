import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/image_url_helper.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/snackbar_helper.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _bodyController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _removeExistingImage = false;

  @override
  void initState() {
    super.initState();
    _bodyController.text = widget.post.body;
  }

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
      _removeExistingImage = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _removeExistingImage = true;
    });
  }

  Future<void> _updatePost() async {
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      showErrorSnackBar(context, 'Gönderi içeriği boş olamaz');
      return;
    }

    final updatedPost = await context.read<PostProvider>().updatePost(
      post: widget.post,
      body: body,
      image: _selectedImage,
      removeImage: _removeExistingImage,
    );

    if (!mounted) return;

    if (updatedPost != null) {
      showSuccessSnackBar(context, 'Gönderi güncellendi');
      Navigator.of(context).pop(updatedPost);
    } else {
      showErrorSnackBar(context, 'Gönderi güncellenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PostProvider>().isLoading;
    final currentImage = ImageUrlHelper.resolve(widget.post.image);
    final showCurrentImage =
        !_removeExistingImage && _selectedImage == null && currentImage != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Gönderiyi Düzenle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SectionCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Gönderiyi Düzenle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Metni güncelle veya görselini değiştir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _bodyController,
                  label: 'Gönderi içeriği',
                  hint: 'Bugün ne paylaşmak istersin?',
                  icon: Icons.notes_outlined,
                  minLines: 6,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null)
                  _ImagePreview(
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (showCurrentImage)
                  _ImagePreview(
                    child: Image.network(
                      currentImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                  )
                else
                  _ImagePickerBox(onPressed: isLoading ? null : _pickImage),
                if (_selectedImage != null || showCurrentImage) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: isLoading ? null : _pickImage,
                        icon: const Icon(Icons.image_search_outlined),
                        label: const Text('Görseli değiştir'),
                      ),
                      TextButton.icon(
                        onPressed: isLoading ? null : _removeImage,
                        icon: const Icon(Icons.close),
                        label: const Text('Seçilen görseli kaldır'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Güncelle',
                  icon: Icons.save_outlined,
                  isLoading: isLoading,
                  onPressed: _updatePost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(height: 220, width: double.infinity, child: child),
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
