class Dhikr {
  final String text;
  final int count;
  final String description;

  Dhikr({required this.text, required this.count, this.description = ''});
}

class DhikrCategory {
  final String title;
  final List<Dhikr> items;
  final String icon;

  DhikrCategory({required this.title, required this.items, required this.icon});
}