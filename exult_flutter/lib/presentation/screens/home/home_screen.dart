import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exult'),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteConstants.pricing),
            child: const Text('Pricing'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.howItWorks),
            child: const Text('How It Works'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.contact),
            child: const Text('Contact'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.go(RouteConstants.signIn),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.all(64),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appTagline,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go(RouteConstants.pricing),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('View Pricing', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),

            // Value Propositions
            Container(
              padding: const EdgeInsets.all(32),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _ValueCard(
                    icon: Icons.auto_stories,
                    title: 'Flexible Subscriptions',
                    description:
                        'Choose from 1, 3, or 5 book plans with monthly or annual billing options.',
                  ),
                  _ValueCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Refundable Deposits',
                    description:
                        'Pay a small deposit when borrowing books. Get it back when you return them.',
                  ),
                  _ValueCard(
                    icon: Icons.people,
                    title: 'Community Lending',
                    description:
                        'Lend your own books to subscribers and earn money while helping readers.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
