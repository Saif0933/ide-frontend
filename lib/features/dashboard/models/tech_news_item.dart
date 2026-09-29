class TechNewsItem {
  final String id;
  final String category;
  final String title;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String? description;

  TechNewsItem({
    required this.id,
    required this.category,
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.description,
  });

  factory TechNewsItem.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Tech Update';
    return TechNewsItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _inferCategory(title, json['tags']?.toString() ?? ''),
      title: title,
      url: json['url'] as String? ?? '',
      source: json['user']?['name'] as String? ?? json['readable_publish_date'] as String? ?? 'Dev.to Tech',
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at']) ?? DateTime.now() : DateTime.now(),
      description: json['description'] as String?,
    );
  }

  static String _inferCategory(String title, String tags) {
    final lower = '$title $tags'.toLowerCase();
    if (lower.contains('ai') || lower.contains('gpt') || lower.contains('llm') || lower.contains('claude') || lower.contains('openai')) {
      return 'AI News';
    }
    if (lower.contains('security') || lower.contains('cyber') || lower.contains('attack') || lower.contains('breach') || lower.contains('hack')) {
      return 'Cybersecurity';
    }
    if (lower.contains('india') || lower.contains('delhi') || lower.contains('bengaluru') || lower.contains('jio') || lower.contains('hazaribagh')) {
      return 'India Tech';
    }
    if (lower.contains('cloud') || lower.contains('aws') || lower.contains('azure') || lower.contains('devops') || lower.contains('docker') || lower.contains('kubernetes')) {
      return 'Cloud & DevOps';
    }
    if (lower.contains('local') || lower.contains('gov') || lower.contains('portal') || lower.contains('district')) {
      return 'Local News';
    }
    return 'Tech News';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
