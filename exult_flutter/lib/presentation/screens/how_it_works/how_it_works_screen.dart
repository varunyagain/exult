import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exult'),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteConstants.home),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.howItWorks),
            child: const Text('How It Works'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.pricing),
            child: const Text('Pricing'),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simple steps to start borrowing books',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Steps
                  const _StepCard(
                    icon: '📍',
                    stepNumber: 1,
                    title: 'Select Location & Slot',
                    description: 'Choose delivery address and time.',
                  ),
                  const _StepCard(
                    icon: '✅',
                    stepNumber: 2,
                    title: 'Serviceability Check',
                    description: 'Proceed only if location is covered.',
                  ),
                  const _StepCard(
                    icon: '💳',
                    stepNumber: 3,
                    title: 'Choose Subscription',
                    description: 'Monthly, yearly or free trial.',
                  ),
                  const _StepCard(
                    icon: '📚',
                    stepNumber: 4,
                    title: 'Pick Books',
                    description: 'View availability and deposits.',
                  ),
                  const _StepCard(
                    icon: '🚚',
                    stepNumber: 5,
                    title: 'Delivery & Borrow',
                    description: 'Books delivered to your doorstep.',
                  ),
                  const _StepCard(
                    icon: '🔁',
                    stepNumber: 6,
                    title: 'Return or Forfeit',
                    description: 'Return on time for deposit refund.',
                  ),

                  const SizedBox(height: 48),

                  // CTA
                  ElevatedButton(
                    onPressed: () => context.go(RouteConstants.pricing),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text('View Pricing', style: TextStyle(fontSize: 18)),
                    ),
                  ),

                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String icon;
  final int stepNumber;
  final String title;
  final String description;

  const _StepCard({
    required this.icon,
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Step $stepNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
