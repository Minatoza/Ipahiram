import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

/// Tap to take or choose a photo of the item. Resizes on pick (maxWidth
/// 800) so the base64 string saved in the Loan stays a reasonable size.
/// Works on web, Android and iOS through the same image_picker API.
class PhotoPickerField extends StatelessWidget {
  final String? photoBase64;
  final ValueChanged<String?> onChanged;

  const PhotoPickerField({
    super.key,
    required this.photoBase64,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 75,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    onChanged(base64Encode(bytes));
  }

  Future<void> _showSourceSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ImageSource.gallery);
              },
            ),
            if (photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSourceSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: photoBase64 == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_rounded,
                      color: AppColors.onSurfaceVariant, size: 28),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add a photo (optional)',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              )
            : Image.memory(base64Decode(photoBase64!), fit: BoxFit.cover),
      ),
    );
  }
}