import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/quran_provider.dart';
import 'package:app/screens/quran_screens.dart';
import 'package:app/screens/prayer_times_screen.dart';
import 'package:app/screens/azkar_screen.dart';
import 'package:app/models/quran_models.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final pages = [
      const HomeDashboard(),
      const SurahListScreen(),
      const PrayerTimesScreen(),
      const AzkarAndBookmarksScreen(),
    ];

    return Scaffold(
      body: pages[provider.activeTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.activeTabIndex,
        onDestinationSelected: (idx) => provider.setActiveTab(idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'المصحف'),
          NavigationDestination(icon: Icon(Icons.access_time), label: 'المواقيت'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'الأذكار والمحفوظات'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuranProvider>(context);
    final availableSurahs = provider.availableSurahsForSelectedReciter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleDarkMode(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBannerCard(context),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر القارئ'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: Text(provider.selectedReciter.name),
              subtitle: Text('${provider.selectedReciter.rewaya} (${availableSurahs.length} سورة متاحة)'),
              trailing: const Icon(Icons.search),
              onTap: () => _showSearchPicker<Reciter>(
                context,
                title: 'ابحث عن قارئ',
                items: provider.reciters,
                itemTitle: (r) => r.name,
                itemSubtitle: (r) => r.rewaya,
                onSelected: (r) => provider.setSelectedReciter(r),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('اختر السورة'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Text('سورة ${provider.selectedSurah.name}'),
              subtitle: Text('${provider.selectedSurah.versesCount} آية - ${provider.selectedSurah.revelationType}'),
              trailing: const Icon(Icons.search),
              onTap: () => _showSearchPicker<Surah>(
                context,
                title: 'اختر السورة (${availableSurahs.length} سورة)',
                items: availableSurahs,
                itemTitle: (s) => 'سورة ${s.name}',
                itemSubtitle: (s) => '${s.versesCount} آية - ${s.revelationType}',
                onSelected: (s) => provider.setSelectedSurah(s),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.playCurrentSurah(),
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text('تشغيل الصوت', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildDownloadButton(context, provider, provider.selectedReciter, provider.selectedSurah),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahReaderScreen(surah: provider.selectedSurah),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_stories, size: 20),
                  label: const Text('قراءة المصحف', style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.teal, width: 1.5),
                    foregroundColor: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          if (provider.hasAudioStarted) ...[
            const SizedBox(height: 20),
            _buildMiniPlayer(context, provider),
          ]
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, QuranProvider provider, Reciter reciter, Surah surah) {
    final isDownloaded = provider.isSurahDownloaded(reciter.id, surah.id);
    final isDownloading = provider.isSurahDownloading(reciter.id, surah.id);

    if (isDownloading) {
      return Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDownloaded ? Colors.teal.shade100 : Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isDownloaded ? Icons.download_done : Icons.file_download_outlined,
          color: Colors.teal,
          size: 26,
        ),
        tooltip: isDownloaded ? 'محملة في المحفوظات' : 'تحميل السورة',
        onPressed: () async {
          if (isDownloaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('سورة ${surah.name} محملة بالفعل في تبويب المحفوظات'),
                action: SnackBarAction(
                  label: 'عرض المحفوظات',
                  onPressed: () => provider.setActiveTab(3),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('بدأ تحميل سورة ${surah.name} بصوت ${reciter.name}...')),
            );
            final success = await provider.downloadSurah(reciter, surah);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'تم تحميل سورة ${surah.name} وإضافتها إلى تبويب المحفوظات'
                      : 'تعذر تحميل سورة ${surah.name}، يرجى المحاولة لاحقاً'),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'آية اليوم',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '«الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '[ سورة الرعد: 28 ]',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );

  Widget _buildMiniPlayer(BuildContext context, QuranProvider provider) {
    final isDownloaded = provider.isSurahDownloaded(provider.selectedReciter.id, provider.selectedSurah.id);
    final isDownloading = provider.isSurahDownloading(provider.selectedReciter.id, provider.selectedSurah.id);

    return Card(
      color: Colors.teal.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            title: Text('جاري التشغيل: سورة ${provider.selectedSurah.name}'),
            subtitle: Text('${provider.selectedReciter.name}${isDownloaded ? 