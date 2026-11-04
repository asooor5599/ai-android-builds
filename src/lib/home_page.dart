import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';
import 'package:app/settings_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);
    final progress = (provider.count / provider.target).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الذكية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const Directionality(
                textDirection: TextDirection.rtl,
                child: SettingsDialog(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildDhikrSelector(context, provider),
          const Spacer(),
          _buildCounterDisplay(context, provider, progress),
          const Spacer(),
          _buildActionButtons(provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector(BuildContext context, TasbihProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.currentDhikr,
          isExpanded: true,
          items: provider.dhikrList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) provider.setDhikr(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildCounterDisplay(BuildContext context, TasbihProvider provider, double progress) {
    return GestureDetector(
      onTap: () => provider.increment(),
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'الهدف: ${provider.target}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TasbihProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.refresh,
          label: 'تصفير',
          onTap: () => provider.reset(),
          color: Colors.orange,
        ),
        Column(
          children: [
            Text('إجمالي التسبيحات', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('${provider.totalCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        _ActionButton(
          icon: provider.vibrationEnabled ? Icons.vibration : Icons.mobile_off,
          label: 'اهتزاز',
          onTap: () => provider.toggleVibration(),
          color: provider.vibrationEnabled ? Colors.teal : Colors.grey,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}