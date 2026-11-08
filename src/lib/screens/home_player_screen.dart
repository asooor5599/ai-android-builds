import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/models/quran_models.dart';
import 'package:app/services/quran_service.dart';

class HomePlayerScreen extends StatelessWidget {
  const HomePlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم - مشغل التلاوات'),
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'تغيير المظهر',
            onPressed: () => provider.toggleDarkMode(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBannerCard(context),
          const SizedBox(height: 16),
          _buildSectionTitle('١. اختر القارئ'),
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              title: Text(
                provider.selectedReciter.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(provider.selectedReciter.rewaya),
              trailing: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.teal),
              onTap: () => _showPickerModal<Reciter>(
                context,
                title: 'اختر القارئ المفضّل',
                items: provider.reciters,
                itemTitle: (r) => r.name,
                itemSubtitle: (r) => r.rewaya,
                onSelected: (r) => provider.setSelectedReciter(r),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('٢. اختر السورة'),
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, color: Colors.teal),
              ),
              title: Text(
                'سورة ${provider.selectedSurah.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('${provider.selectedSurah.versesCount} آية - ${provider.selectedSurah.revelationType}'),
              trailing: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.teal),
              onTap: () => _showPickerModal<Surah>(
                context,
                title: 'اختر السورة الكريمة',
                items: QuranService.allSurahs,
                itemTitle: (s) => 'سورة ${s.name}',
                itemSubtitle: (s) => '${s.versesCount} آية - ${s.revelationType}',
                onSelected: (s) => provider.setSelectedSurah(s),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAudioPlayerCard(context, provider),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'القرآن ربيع القلوب',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '«الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard(BuildContext context, QuranProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.audiotrack, size: 36, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Text(
              'سورة ${provider.selectedSurah.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'القارئ: ${provider.selectedReciter.name}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Slider(
              value: provider.position.inSeconds.toDouble().clamp(
                    0.0,
                    provider.duration.inSeconds.toDouble() > 0
                        ? provider.duration.inSeconds.toDouble()
                        : 1.0,
                  ),
              max: provider.duration.inSeconds.toDouble() > 0
                  ? provider.duration.inSeconds.toDouble()
                  : 1.0,
              activeColor: Colors.teal,
              onChanged: (v) => provider.seekAudio(Duration(seconds: v.toInt())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(provider.position), style: const TextStyle(fontSize: 12)),
                  Text(_formatDuration(provider.duration), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 32),
                  onPressed: () => provider.playPreviousSurah(),
                ),
                const SizedBox(width: 12),
                if (provider.isBuffering)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.teal),
                    ),
                  )
                else
                  FloatingActionButton(
                    elevation: 2,
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      if (provider.hasAudioStarted) {
                        if (provider.isPlaying) {
                          provider.pauseAudio();
                        } else {
                          provider.resumeAudio();
                        }
                      } else {
                        provider.playCurrentSurah();
                      }
                    },
                    child: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow, size: 36),
                  ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 32),
                  onPressed: () => provider.playNextSurah(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => provider.setActiveTab(1),
              icon: const Icon(Icons.menu_book, color: Colors.teal),
              label: const Text('قراءة السورة بالكلمات', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerModal<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemTitle,
    required String Function(T) itemSubtitle,
    required Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _SearchablePickerWidget<T>(
        title: title,
        items: items,
        itemTitle: itemTitle,
        itemSubtitle: itemSubtitle,
        onSelected: onSelected,
      ),
    );
  }
}

class _SearchablePickerWidget<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemTitle;
  final String Function(T) itemSubtitle;
  final Function(T) onSelected;

  const _SearchablePickerWidget({
    required this.title,
    required this.items,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.onSelected,
  });

  @override
  State<_SearchablePickerWidget<T>> createState() => _SearchablePickerWidgetState<T>();
}

class _SearchablePickerWidgetState<T> extends State<_SearchablePickerWidget<T>> {
  late List<T> _filtered;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  void _filter(String q) {
    setState(() {
      _query = q;
      _filtered = widget.items.where((item) {
        final t = widget.itemTitle(item).toLowerCase();
        final s = widget.itemSubtitle(item).toLowerCase();
        return t.contains(q.toLowerCase()) || s.contains(q.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'ابحث عن اسم القارئ أو السورة...',
              prefixIcon: const Icon(Icons.search, color: Colors.teal),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('لا توجد نتائج مطابقة'))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = _filtered[i];
                      return ListTile(
                        title: Text(widget.itemTitle(item), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(widget.itemSubtitle(item)),
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
