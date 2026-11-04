import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models.dart';
import 'package:app/quran_provider.dart';

class SurahView extends StatefulWidget {
  final Surah surah;
  const SurahView({super.key, required this.surah});

  @override
  State<SurahView> createState() => _SurahViewState();
}

class _SurahViewState extends State<SurahView> {
  late Future<List<Ayah>> _ayahsFuture;

  @override
  void initState() {
    super.initState();
    _ayahsFuture = context.read<QuranProvider>().getAyahs(widget.surah.number);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().saveLastRead(widget.surah.number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء التحميل: ${snapshot.error}'));
          }
          final ayahs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ayahs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader();
              }
              final ayah = ayahs[index - 1];
              return AyahTile(ayah: ayah, surahNumber: widget.surah.number);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    if (widget.surah.number == 1 || widget.surah.number == 9) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: const Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif'),
      ),
    );
  }
}

class AyahTile extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  const AyahTile({super.key, required this.ayah, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    String text = ayah.text;
    // Remove Bismillah from first ayah if it's not Fatiha and it exists in the string
    if (surahNumber != 1 && ayah.numberInSurah == 1 && text.startsWith('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
      text = text.replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '').trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ayah.numberInSurah % 2 == 0 
                ? Colors.transparent 
                : Theme.of(context).primaryColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    height: 1.8,
                    fontFamily: 'serif',
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.secondary),
                    ),
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}