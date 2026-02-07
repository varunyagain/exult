import 'package:flutter/material.dart';

class AdminFinancialsScreen extends StatelessWidget {
  const AdminFinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financials'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Financials',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
