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
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdhkarDetailScreen(category: category),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(category.icon, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category.items.length} أذكار',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdhkarDetailScreen extends StatefulWidget {
  final DhikrCategory category;
  const AdhkarDetailScreen({super.key, required this.category});

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late List<int> _remainingCounts;

  @override
  void initState() {
    super.initState();
    _remainingCounts = widget.category.items.map((item) => item.count).toList();
  }

  void _updateCount(int index, int newRemaining) {
    setState(() {
      _remainingCounts[index] = newRemaining;
    });
  }

  double get _progress {
    int totalInitial = widget.category.items.fold(0, (sum, item) => sum + item.count);
    if (totalInitial == 0) return 1.0;
    int totalRemaining = _remainingCounts.fold(0, (sum, count) => sum + count);
    int completed = totalInitial - totalRemaining;
    return (completed / totalInitial).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          return DhikrItemCard(
            dhikr: widget.category.items[index],
            remaining: _remainingCounts[index],
            onChanged: (newVal) => _updateCount(index, newVal),
          );
        },
      ),
    );
  }
}

class DhikrItemCard extends StatelessWidget {
  final Dhikr dhikr;
  final int remaining;
  final ValueChanged<int> onChanged;

  const DhikrItemCard({
    super.key,
    required this.dhikr,
    required this.remaining,
    required this.onChanged,
  });

  void _decrement() {
    if (remaining > 0) {
      onChanged(remaining - 1);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = remaining == 0;

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
                dhikr.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => onChanged(dhikr.count),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.teal : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDone ? 'تم' : '$remaining',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}