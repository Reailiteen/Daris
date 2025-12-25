import 'package:flutter/material.dart';

enum WebsiteCategory {
  social('Social Media'),
  news('News'),
  entertainment('Entertainment'),
  shopping('Shopping'),
  gaming('Gaming'),
  other('Other');

  final String displayName;
  const WebsiteCategory(this.displayName);

  IconData get icon {
    switch (this) {
      case WebsiteCategory.social: return Icons.people_alt;
      case WebsiteCategory.news: return Icons.newspaper;
      case WebsiteCategory.entertainment: return Icons.play_circle_fill;
      case WebsiteCategory.shopping: return Icons.shopping_cart;
      case WebsiteCategory.gaming: return Icons.sports_esports;
      default: return Icons.public;
    }
  }

  static WebsiteCategory fromString(String value) {
    return WebsiteCategory.values.firstWhere(
      (e) => e.name == value || e.displayName == value,
      orElse: () => WebsiteCategory.other,
    );
  }
}
