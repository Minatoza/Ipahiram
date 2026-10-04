import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme.dart';

/// A square photo for a loan's item, or a keyword-guessed icon when no
/// photo has been taken. Used on Home (small), History (small) and Item
/// Detail (large) so every screen shows the same thing.
class ItemPhoto extends StatelessWidget {
  final String itemName;
  final String? photoBase64;
  final double size;

  const ItemPhoto({
    super.key,
    required this.itemName,
    required this.photoBase64,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size >= 100 ? 16.0 : 10.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: AppColors.avatarBackground,
        child: photoBase64 == null
            ? Icon(_iconFor(itemName), color: AppColors.primary, size: size * 0.45)
            : Image.memory(
                base64Decode(photoBase64!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(_iconFor(itemName), color: AppColors.primary, size: size * 0.45),
              ),
      ),
    );
  }

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('drill') || n.contains('screwdriver') || n.contains('tool')) {
      return Icons.handyman_rounded;
    }
    if (n.contains('charger') || n.contains('cable') || n.contains('battery')) {
      return Icons.power_rounded;
    }
    if (n.contains('game') || n.contains('board')) {
      return Icons.sports_esports_rounded;
    }
    if (n.contains('book')) {
      return Icons.menu_book_rounded;
    }
    return Icons.inventory_2_rounded;
  }
}