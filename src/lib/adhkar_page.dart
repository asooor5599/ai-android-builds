import 'package:flutter/material.dart';

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
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
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
    {'text': 'رضيت بالله رباً، وبالإسلام ديناً، وبمحمد صلى الله عليه وسلم نبياً.', 'count': 3},
  ];

  static const evening = [
    {'text': 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له.', 'count': 1},
    {'text': 'اللهم بك أمسينا، وبك أصبحنا، وبك نحيا، وبك نموت، وإليك المصير.', 'count': 1},
    {'text': 'أعوذ بكلمات الله التامات من شر ما خلق.', 'count': 3},
    {'text': 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.', 'count': 1},
    {'text': 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.', 'count': 7},
  ];

  @override
  Widget build(BuildContext context) {
    final list = type == 'morning' ? morning : evening;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list[index]['text'] as String, style: const TextStyle(fontSize: 18, height: 1.6)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('التكرار: ${list[index]['count']}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}