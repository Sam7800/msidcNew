import 'package:flutter/material.dart';

/// Category model for project classification
class Category {
  final int? id;
  final String name;
  final String? description;
  final String colorHex;
  final String iconName;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.colorHex = '#0061FF',
    this.iconName = 'folder',
    this.displayOrder = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create Category from database map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      colorHex: map['color_hex'] as String? ?? '#0061FF',
      iconName: map['icon_name'] as String? ?? 'folder',
      displayOrder: map['display_order'] as int? ?? 0,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convert Category to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'color_hex': colorHex,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      case 'construction':
        return Icons.construction;
      case 'account_balance':
        return Icons.account_balance;
      case 'location_city':
        return Icons.location_city;
      case 'domain':
        return Icons.domain;
      case 'corporate_fare':
        return Icons.corporate_fare;
      case 'factory':
        return Icons.factory;
      case 'store':
        return Icons.store;
      case 'workspaces':
        return Icons.workspaces;
      default:
        return Icons.folder;
    }
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, colorHex: $colorHex, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.colorHex == colorHex &&
        other.iconName == iconName &&
        other.displayOrder == displayOrder &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      colorHex,
      iconName,
      displayOrder,
      isActive,
    );
  }
}
