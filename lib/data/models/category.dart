import 'package:flutter/material.dart';

/// Category model for project classification
class Category {
  final int id;
  final String name;
  final String colorHex;
  final String iconName;

  Category({
    required this.id,
    required this.name,
    this.colorHex = '#0061FF',
    this.iconName = 'folder',
  });

  /// Get Color object from hex string
  Color getColor() {
    try {
      final hexColor = colorHex.replaceAll('#', '');
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return const Color(0xFF0061FF); // Default blue
    }
  }

  /// Get IconData from icon name
  IconData getIcon() {
    switch (iconName.toLowerCase()) {
      case 'festival':
        return Icons.festival;
      case 'handshake':
        return Icons.handshake;
      case 'apartment':
        return Icons.apartment;
      case 'route':
        return Icons.route;
      case 'business':
        return Icons.business;
      case 'engineering':
        return Icons.engineering;
      default:
        return Icons.folder;
    }
  }

  /// Convert Category to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_name': iconName,
    };
  }

  /// Create Category from Map (database row)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String? ?? '#0061FF',
      iconName: map['icon_name'] as String? ?? 'folder',
    );
  }
}
