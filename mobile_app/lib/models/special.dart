class Special {
  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const Special({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory Special.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['startDate'] as String);
    final end = DateTime.parse(json['endDate'] as String);
    final period =
        '${_fmt(start)} – ${_fmt(end)}';
    return Special(
      id: json['id'] as String,
      tag: json['tag'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageAsset: json['imageUrl'] as String? ?? '',
      period: period,
      startDate: start,
      endDate: end,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
}
