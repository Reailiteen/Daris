import 'package:uuid/uuid.dart';
import 'website_category.dart';

class BlockedWebsite {
  final String id;
  final String domain;
  final String displayName;
  final String iconName;
  final bool isEnabled;
  final WebsiteCategory category;

  BlockedWebsite({
    String? id,
    required this.domain,
    required this.displayName,
    this.iconName = 'globe',
    this.isEnabled = true,
    this.category = WebsiteCategory.other,
  }) : id = id ?? const Uuid().v4();

  String get formattedDomain {
    return domain.startsWith('www.') ? domain.substring(4) : domain;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'displayName': displayName,
      'iconName': iconName,
      'isEnabled': isEnabled,
      'category': category.name,
    };
  }

  factory BlockedWebsite.fromJson(Map<String, dynamic> json) {
    return BlockedWebsite(
      id: json['id'],
      domain: json['domain'],
      displayName: json['displayName'],
      iconName: json['iconName'] ?? 'globe',
      isEnabled: json['isEnabled'] ?? true,
      category: WebsiteCategory.fromString(json['category']),
    );
  }
}
