import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/tasbih_provider.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'إجمالي التسبيح: ${provider.totalCounter}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                provider.increment();
              },
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
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
                      const Text('اضغط للتسبيح'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: provider.resetSession,
              icon: const Icon(Icons.restart_alt),
              label: const Text('تصفير العداد الحالي'),
            ),
          ],
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