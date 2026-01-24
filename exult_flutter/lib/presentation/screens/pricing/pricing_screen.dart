import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:intl/intl.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Title Section
                  const SizedBox(height: 32),
                  Text(
                    'Simple Pricing',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how many books you want at a time',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Pricing Cards
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _PricingCard(
                        icon: '📘',
                        title: 'One Book',
                        subtitle: 'Perfect for casual readers',
                        tier: SubscriptionTier.oneBook,
                        features: const [
                          'Borrow 1 book at a time',
                          'Unlimited swaps',
                          'Full catalog access',
                          'Home delivery & pickup',
                        ],
                      ),
                      _PricingCard(
                        icon: '📗',
                        title: 'Three Books',
                        subtitle: 'For regular readers',
                        tier: SubscriptionTier.threeBooks,
                        features: const [
                          'Borrow up to 3 books',
                          'Priority delivery slots',
                          'Community-listed books',
                          'Unlimited swaps',
                        ],
                        highlighted: true,
                      ),
                      _PricingCard(
                        icon: '📕',
                        title: 'Five Books',
                        subtitle: 'For avid readers & families',
                        tier: SubscriptionTier.fiveBooks,
                        features: const [
                          'Borrow up to 5 books',
                          'Priority delivery & pickup',
                          'Early access to new arrivals',
                          'Best value plan',
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 64),

                  // FAQ Section
                  Text(
                    'FAQs',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Everything you need to know',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 32),

                  const _FAQItem(
                    question: 'How does the subscription work?',
                    answer:
                        'You pay a monthly or annual fee to access the catalog and borrow books up to your plan limit.',
                  ),
                  const _FAQItem(
                    question: 'What about deposits?',
                    answer:
                        'Each book has a refundable security deposit, paid only when you borrow. It\'s refunded once the book is returned on time.',
                  ),
                  const _FAQItem(
                    question: 'Is there a free trial?',
                    answer:
                        'Yes. You can subscribe for free by paying a 2× deposit, which is fully refundable.',
                  ),
                  const _FAQItem(
                    question: 'How are disputes handled?',
                    answer:
                        'In case of disputes, both subscriptions are cancelled and the deposit is split equally. The matter is considered resolved.',
                  ),
                  const _FAQItem(
                    question: 'Where do you deliver?',
                    answer:
                        'We operate only in serviceable areas. Non-serviceable locations cannot proceed with checkout.',
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

class _PricingCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final SubscriptionTier tier;
  final List<String> features;
  final bool highlighted;

  const _PricingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tier,
    required this.features,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final monthlyPrice = currencyFormat.format(tier.monthlyPrice);
    final annualPrice = currencyFormat.format(tier.annualPrice);
    final savings = currencyFormat.format(
      (tier.monthlyPrice * 12) - tier.annualPrice,
    );

    return SizedBox(
      width: 320,
      child: Card(
        elevation: highlighted ? 12 : 8,
        child: Container(
          decoration: highlighted
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$icon $title',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
                const SizedBox(height: 24),

                // Monthly Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      monthlyPrice,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Annual Price
                Text(
                  '$annualPrice / year (save $savings)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

                // Features
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to signup/subscribe flow
                      context.go(RouteConstants.signUp);
                    },
                    child: const Text('Get Started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                answer,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
