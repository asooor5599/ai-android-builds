import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';
import 'package:app/settings_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = provider.target > 0 ? (provider.count / provider.target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(provider.vibrationEnabled ? Icons.vibration : Icons.vibration_outlined, 
                 color: provider.vibrationEnabled ? colorScheme.primary : null),
            onPressed: provider.toggleVibration,
            tooltip: 'الاهتزاز',
          ),
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: provider.toggleTheme,
            tooltip: 'الوضع الليلي',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDhikrCard(context, provider),
            const Spacer(),
            _buildMainCounter(context, provider, progress),
            const Spacer(),
            _buildStatsAndActions(context, provider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCard(BuildContext context, TasbihProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.currentDhikr,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: provider.dhikrList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (val) => val != null ? provider.setDhikr(val) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCounter(BuildContext context, TasbihProvider provider, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: provider.increment,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${provider.count}',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'الهدف: ${provider.target}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsAndActions(BuildContext context, TasbihProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            icon: Icons.refresh,
            label: 'تصفير',
            onPressed: provider.reset,
            color: Colors.orange,
          ),
          Column(
            children: [
              Text(
                'إجمالي التسبيح',
                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              ),
              Text(
                '${provider.totalCount}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          _ActionButton(
            icon: Icons.track_changes,
            label: 'الهدف',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const Directionality(
                textDirection: TextDirection.rtl,
                child: SettingsDialog(),
              ),
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}