import 'package:flutter/material.dart';

Color colorFromHex(String hex, {Color fallback = Colors.transparent}) {
  final normalized = hex.replaceFirst('#', '').trim();
  if (normalized.length != 6 && normalized.length != 8) {
    return fallback;
  }

  final value = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(value, radix: 16));
}

IconData iconFromKey(String key) {
  switch (key) {
    case 'play_arrow_rounded':
      return Icons.play_arrow_rounded;
    case 'castle_rounded':
      return Icons.castle_rounded;
    case 'auto_awesome_rounded':
      return Icons.auto_awesome_rounded;
    case 'lock_outline_rounded':
      return Icons.lock_outline_rounded;
    case 'tag_rounded':
      return Icons.tag_rounded;
    case 'gesture_rounded':
      return Icons.gesture_rounded;
    case 'view_week_rounded':
      return Icons.view_week_rounded;
    case 'add_circle_outline_rounded':
      return Icons.add_circle_outline_rounded;
    case 'format_list_numbered_rounded':
      return Icons.format_list_numbered_rounded;
    case 'auto_awesome_mosaic_rounded':
      return Icons.auto_awesome_mosaic_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}
