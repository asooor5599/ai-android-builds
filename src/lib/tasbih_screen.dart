import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);
    final isInfinite = provider.goal == 0;
    final progress = isInfinite ? 0.0 : (provider.sessionCounter / provider.goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context, provider),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'إجمالي التسبيح: ${provider.totalCounter}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(value: 33, label: Text('33')),
                  ButtonSegment<int>(value: 100, label: Text('100')),
                  ButtonSegment<int>(value: 0, label: Text('∞')),
                ],
                selected: {provider.goal},
                onSelectionChanged: (Set<int> newSelection) {
                  provider.setGoal(newSelection.first);
                },
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  provider.increment();
                  if (!isInfinite && provider.sessionCounter == provider.goal) {
                    HapticFeedback.mediumImpact();
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isInfinite ? _pulseController.value : 1.0,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: isInfinite ? null : progress,
                            strokeWidth: 12,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${provider.sessionCounter}',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isInfinite ? 'تسبيح حر' : 'الهدف: ${provider.goal}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: provider.resetSession,
                icon: const Icon(Icons.restart_alt),
                label: const Text('تصفير العداد الحالي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, TasbihProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير العداد'),
        content: const Text('هل أنت متأكد من تصفير إجمالي التسبيح؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              provider.resetTotal();
              Navigator.pop(context);
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}