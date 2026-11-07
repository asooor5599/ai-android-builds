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
        title: const Text(
          'عداد التسبيح',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'reset_current') {
                _showResetDialog(context, false);
              } else if (value == 'reset_all') {
                _showResetDialog(context, true);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_current',
                child: Text('تصفير الذكر الحالي'),
              ),
              const PopupMenuItem(
                value: 'reset_all',
                child: Text('تصفير جميع العدادات'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTargetSelector(context, provider),
            const SizedBox(height: 16),
            _buildDhikrChips(provider, theme),
            const Spacer(),
            _buildCounterCircle(provider, theme),
            const Spacer(),
            _buildMainButton(provider, theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector(BuildContext context, DhikrProvider provider) {
    final targets = [33, 100, 1000, 0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('الهدف: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            children: targets.map((target) {
              final isSelected = provider.targetCount == target;
              final label = target == 0 ? 'مفتوح' : '$target';
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) provider.setTargetCount(target);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrChips(DhikrProvider provider, ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.dhikrList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dhikr = provider.dhikrList[index];
          final isSelected = provider.currentIndex == index;
          return ChoiceChip(
            label: Text(
              dhikr,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            onSelected: (selected) {
              if (selected) provider.selectDhikr(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildCounterCircle(DhikrProvider provider, ThemeData theme) {
    final count = provider.currentCount;
    final target = provider.targetCount;
    final progress = target > 0 ? (count % target) / target : 0.0;

    return Container(
      width: 260,
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (target > 0)
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progress == 0 && count > 0 ? 1.0 : progress,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                color: theme.colorScheme.primary,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.currentDhikr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (target > 0)
                Text(
                  'الدورة: ${(count / target).floor() + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(DhikrProvider provider, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.increment();
        if (provider.targetCount > 0 &&
            provider.currentCount > 0 &&
            provider.currentCount % provider.targetCount == 0) {
          HapticFeedback.vibrate();
        }
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.touch_app,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, bool isAll) {
    final provider = Provider.of<DhikrProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAll ? 'تصفير جميع العدادات' : 'تصفير العداد الحالي'),
        content: Text(
          isAll
              ? 'هل أنت متأكد من رغبتك في تصفير جميع الأذكار؟'
              : 'هل أنت متأكد من رغبتك في تصفير عداد (${provider.currentDhikr})؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (isAll) {
                provider.resetAll();
              } else {
                provider.resetCurrent();
              }
              Navigator.pop(context);
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}