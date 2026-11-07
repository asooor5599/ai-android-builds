import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/models.dart';
import 'package:app/data.dart';

class AdhkarListScreen extends StatelessWidget {
  const AdhkarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار اليومية'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adhkarData.length,
        itemBuilder: (context, index) {
          final category = adhkarData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
              title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${category.items.length} أذكار'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdhkarDetailScreen(category: category),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdhkarDetailScreen extends StatelessWidget {
  final DhikrCategory category;
  const AdhkarDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          return DhikrItemCard(dhikr: category.items[index]);
        },
      ),
    );
  }
}

class DhikrItemCard extends StatefulWidget {
  final Dhikr dhikr;
  const DhikrItemCard({super.key, required this.dhikr});

  @override
  State<DhikrItemCard> createState() => _DhikrItemCardState();
}

class _DhikrItemCardState extends State<DhikrItemCard> {
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.dhikr.count;
  }

  void _decrement() {
    if (_remaining > 0) {
      setState(() => _remaining--);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = _remaining == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDone ? Colors.teal.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: _decrement,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.dhikr.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => setState(() => _remaining = widget.dhikr.count),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.teal : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDone ? 'تم' : '$_remaining',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}