import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'أذكار الصباح'),
              Tab(text: 'أذكار المساء'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdhkarList(type: 'morning'),
            AdhkarList(type: 'evening'),
          ],
        ),
      ),
    );
  }
}

class AdhkarList extends StatelessWidget {
  final String type;
  const AdhkarList({super.key, required this.type});

  static const morning = [
    {'text': 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له.', 'count': 1},
    {'text': 'اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور.', 'count': 1},
    {'text': 'سبحان الله وبحمده: عدد خلقه، ورضا نفسه، وزنة عرشه، ومداد كلماته.', 'count': 3},
    {'text': 'يا حي يا قيوم برحمتك أستغيث أصلح لي شأني كله ولا تكلني إلى نفسي طرفة عين.', 'count': 1},
  ];

  static const evening = [
    {'text': 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له.', 'count': 1},
    {'text': 'اللهم بك أمسينا، وبك أصبحنا، وبك نحيا، وبك نموت، وإليك المصير.', 'count': 1},
    {'text': 'أعوذ بكلمات الله التامات من شر ما خلق.', 'count': 3},
    {'text': 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.', 'count': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final list = type == 'morning' ? morning : evening;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ZikrCard(text: list[index]['text'] as String, total: list[index]['count'] as int);
      },
    );
  }
}

class ZikrCard extends StatefulWidget {
  final String text;
  final int total;
  const ZikrCard({super.key, required this.text, required this.total});

  @override
  State<ZikrCard> createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard> {
  int _current = 0;

  void _increment() {
    if (_current < widget.total) {
      setState(() => _current++);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool done = _current >= widget.total;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: done ? Colors.teal.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: _increment,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: done ? Colors.teal : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_current / ${widget.total}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}