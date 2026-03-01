import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 34),
              ),
              const SizedBox(height: 14),
              const Text(
                '还没有添加补剂',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                '添加您的第一个营养补剂，开始跟踪您的健康投资',
                style: TextStyle(color: Color(0xFF8A8A8A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('添加补剂'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
