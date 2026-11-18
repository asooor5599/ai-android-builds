import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TasbeehProvider(prefs),
      child: const TasbeehApp(),
    ),
  );
}

class TasbeehProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  int _counter = 0;
  int _target = 33;
  int _totalCount = 0;
  int _selectedDhikrIndex = 0;
  bool _hapticsEnabled = true;
  bool _isDarkMode = false;

  final List<String> _presetDhikr = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
  ];

  TasbeehProvider(this.prefs) {
    _counter = prefs.getInt('counter') ?? 0;
    _target = prefs.getInt('target') ?? 33;
    _totalCount = prefs.getInt('totalCount') ?? 0;
    _selectedDhikrIndex = prefs.getInt('selectedDhikrIndex') ?? 0;
    _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  int get counter => _counter;
  int get target => _target;
  int get totalCount => _totalCount;
  int get selectedDhikrIndex => _selectedDhikrIndex;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isDarkMode => _isDarkMode;
  List<String> get presetDhikr => _presetDhikr;
  String get currentDhikr => _presetDhikr[_selectedDhikrIndex];

  void increment() {
    _counter++;
    _totalCount++;
    if (_hapticsEnabled) {
      if (_target > 0 && _counter % _target == 0) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    _saveState();
    notifyListeners();
  }

  void resetCurrent() {
    _counter = 0;
    _saveState();
    notifyListeners();
  }

  void resetTotal() {
    _totalCount = 0;
    _saveState();
    notifyListeners();
  }

  void setTarget(int newTarget) {
    _target = newTarget;
    _saveState();
    notifyListeners();
  }

  void setDhikrIndex(int index) {
    _selectedDhikrIndex = index;
    _counter = 0;
    _saveState();
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _hapticsEnabled = value;
    prefs.setBool('hapticsEnabled', value);
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  void _saveState() {
    prefs.setInt('counter', _counter);
    prefs.setInt('target', _target);
    prefs.setInt('totalCount', _totalCount);
    prefs.setInt('selectedDhikrIndex', _selectedDhikrIndex);
  }
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);

    final primaryBlue = Colors.blue.shade700;
    final accentBlue = Colors.blue.shade400;

    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryBlue,
        secondary: accentBlue,
      ),
      scaffoldBackgroundColor: provider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F6FF),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    return MaterialApp(
      title: 'عداد التسبيح',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد التسبيح', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => provider.toggleDarkMode(!provider.isDarkMode),
            tooltip: 'تغيير المظهر',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Dhikr Selector Dropdown Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: provider.selectedDhikrIndex,
                      icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
                      items: List.generate(
                        provider.presetDhikr.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            provider.presetDhikr[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) provider.setDhikrIndex(val);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Dhikr Display & Counter Circle
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      provider.currentDhikr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Big Counter Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: provider.increment,
                      borderRadius: BorderRadius.circular(140),
                      splashColor: Colors.blue.withValues(alpha: 0.3),
                      highlightColor: Colors.blue.withValues(alpha: 0.1),
                      child: Ink(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade900,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade700.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${provider.counter}',
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (provider.target > 0)
                                Text(
                                  'الهدف: ${provider.target}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Total Counter Info & Reset Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المجموع الكلي: ${provider.totalCount}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'الدورة الحالية: ${provider.counter}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('إعادة ضبط العداد'),
                              content: const Text('هل ترغب في إعادة ضبط العداد الحالي إلى الصفر؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.resetCurrent();
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('إعادة ضبط', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'تصفير العداد',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('الاهتزاز عند الضغط'),
                    subtitle: const Text('تفعيل التغذية الراجعة بالاهتزاز'),
                    value: provider.hapticsEnabled,
                    onChanged: provider.toggleHaptics,
                    secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('الوضع الليلي'),
                    subtitle: const Text('تغيير مظهر التطبيق للون الداكن'),
                    value: provider.isDarkMode,
                    onChanged: provider.toggleDarkMode,
                    secondary: Icon(Icons.dark_mode, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.flag, color: theme.colorScheme.primary),
                title: const Text('هدف التكرار'),
                subtitle: Text('الهدف الحالي: ${provider.target} تكرارات'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final controller = TextEditingController(text: provider.target.toString());
                      return AlertDialog(
                        title: const Text('تحديد الهدف'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'عدد التكرارات',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              final val = int.tryParse(controller.text);
                              if (val != null && val > 0) {
                                provider.setTarget(val);
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('حفظ'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('تصفير إجمالي التسبيحات'),
                subtitle: const Text('حذف العداد الكلي التراكمي'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تأكيد الحذف'),
                      content: const Text('هل أنت تأكد من رغبتك في تصفير المجموع الكلي للتسبيحات؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.resetTotal();
                            Navigator.pop(ctx);
                          },
                          child: const Text('تصفير', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
