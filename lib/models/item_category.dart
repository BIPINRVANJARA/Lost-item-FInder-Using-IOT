import 'package:flutter/material.dart';

enum ItemCategory {
  keys,
  wallet,
  bag,
  electronics,
  documents,
  accessories,
  remotes,
  pets,
  other;

  String get displayName {
    switch (this) {
      case ItemCategory.keys:
        return 'Keys';
      case ItemCategory.wallet:
        return 'Wallet';
      case ItemCategory.bag:
        return 'Bag';
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.remotes:
        return 'Remotes';
      case ItemCategory.pets:
        return 'Pets';
      case ItemCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.keys:
        return Icons.vpn_key_rounded;
      case ItemCategory.wallet:
        return Icons.account_balance_wallet_rounded;
      case ItemCategory.bag:
        return Icons.backpack_rounded;
      case ItemCategory.electronics:
        return Icons.devices_other_rounded;
      case ItemCategory.documents:
        return Icons.badge_rounded;
      case ItemCategory.accessories:
        return Icons.watch_rounded;
      case ItemCategory.remotes:
        return Icons.settings_remote_rounded;
      case ItemCategory.pets:
        return Icons.pets_rounded;
      case ItemCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ItemCategory.keys:
        return const Color(0xFF10B981); // Emerald
      case ItemCategory.wallet:
        return const Color(0xFFF59E0B); // Amber
      case ItemCategory.bag:
        return const Color(0xFF8B5CF6); // Purple
      case ItemCategory.electronics:
        return const Color(0xFF38BDF8); // Sky
      case ItemCategory.documents:
        return const Color(0xFFEC4899); // Pink
      case ItemCategory.accessories:
        return const Color(0xFF06B6D4); // Cyan
      case ItemCategory.remotes:
        return const Color(0xFFEAB308); // Yellow
      case ItemCategory.pets:
        return const Color(0xFFF97316); // Orange
      case ItemCategory.other:
        return const Color(0xFF64748B); // Slate
    }
  }
}
