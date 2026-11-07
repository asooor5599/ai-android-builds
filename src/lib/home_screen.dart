import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/dhikr_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DhikrProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('مسبحة الأذكار', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تصفير العداد',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تصفير العداد'),
                  content: const Text('هل أنت متأكد من رغبتك في تصفير العداد؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.reset();
                        Navigator.pop(context);
                      },
                      child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDhikrSelector(provider, theme),
            const Spacer(),
            _buildCounterDisplay(provider, theme),
            const Spacer(),
            _buildMainButton(provider, theme),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrSelector(DhikrProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختر الذكر:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.dhikrList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dhikr = provider.dhikrList[index];
                final isSelected = provider.currentDhikr == dhikr;
                return ChoiceChip(
                  label: Text(dhikr),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) provider.setDhikr(dhikr);
                  },
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(DhikrProvider provider, ThemeData theme) {
    return Column(
      children: [
        Text(
          provider.currentDhikr,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${provider.count}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(DhikrProvider provider, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        provider.increment();
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.touch_app,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}