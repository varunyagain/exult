import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/subscription_model.dart';
import 'package:exult_flutter/presentation/providers/subscription_provider.dart';
import 'package:intl/intl.dart';

class SubscribeScreen extends ConsumerStatefulWidget {
  const SubscribeScreen({super.key});

  @override
  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {
  SubscriptionTier _selectedTier = SubscriptionTier.threeBooks;
  BillingCycle _selectedCycle = BillingCycle.monthly;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final activeSubscription = ref.watch(activeSubscriptionProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // If user already has an active subscription, show management view
    if (activeSubscription.valueOrNull != null) {
      return _buildSubscriptionManagementView(
        context,
        activeSubscription.valueOrNull!,
        currencyFormat,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.books),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a subscription tier and billing cycle to start borrowing books',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Billing Cycle Toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Billing Cycle',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<BillingCycle>(
                            segments: [
                              ButtonSegment(
                                value: BillingCycle.monthly,
                                label: const Text('Monthly'),
                                icon: const Icon(Icons.calendar_month),
                              ),
                              ButtonSegment(
                                value: BillingCycle.annual,
                                label: const Text('Annual'),
                                icon: const Icon(Icons.calendar_today),
                              ),
                            ],
                            selected: {_selectedCycle},
                            onSelectionChanged: (Set<BillingCycle> selection) {
                              setState(() {
                                _selectedCycle = selection.first;
                              });
                            },
                          ),
                          if (_selectedCycle == BillingCycle.annual)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.savings,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Save up to 2 months with annual billing!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subscription Tier Selection
                  Text(
                    'Select Plan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // Tier Cards
                  ...SubscriptionTier.values.map((tier) {
                    final isSelected = _selectedTier == tier;
                    final price = _selectedCycle == BillingCycle.monthly
                        ? tier.monthlyPrice
                        : tier.annualPrice;
                    final priceLabel = _selectedCycle == BillingCycle.monthly
                        ? '/month'
                        : '/year';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TierCard(
                        tier: tier,
                        price: currencyFormat.format(price),
                        priceLabel: priceLabel,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedTier = tier;
                          });
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Order Summary
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _SummaryRow(
                            label: 'Plan',
                            value: _selectedTier.displayName,
                          ),
                          _SummaryRow(
                            label: 'Billing',
                            value: _selectedCycle.displayName,
                          ),
                          _SummaryRow(
                            label: 'Books at a time',
                            value: '${_selectedTier.maxBooks}',
                          ),
                          const Divider(height: 24),
                          _SummaryRow(
                            label: 'Total',
                            value: currencyFormat.format(
                              _selectedCycle == BillingCycle.monthly
                                  ? _selectedTier.monthlyPrice
                                  : _selectedTier.annualPrice,
                            ),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isProcessing ? null : _handleSubscribe,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Subscribe Now',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms note
                  Text(
                    'By subscribing, you agree to our Terms of Service. '
                    'Your subscription will auto-renew until cancelled.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionManagementView(
    BuildContext context,
    Subscription subscription,
    NumberFormat currencyFormat,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.books),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active subscription card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                subscription.tier.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _DetailRow(
                            icon: Icons.calendar_month,
                            label: 'Billing Cycle',
                            value: subscription.billingCycle.displayName,
                          ),
                          _DetailRow(
                            icon: Icons.library_books,
                            label: 'Books Limit',
                            value:
                                '${subscription.currentBooksCount} / ${subscription.maxBooks} borrowed',
                          ),
                          _DetailRow(
                            icon: Icons.event,
                            label: 'Started',
                            value: dateFormat.format(subscription.startDate),
                          ),
                          _DetailRow(
                            icon: Icons.event_available,
                            label: 'Renews',
                            value: dateFormat.format(subscription.endDate),
                          ),
                          _DetailRow(
                            icon: Icons.payments,
                            label: 'Amount',
                            value: subscription.billingCycle == BillingCycle.monthly
                                ? '${currencyFormat.format(subscription.monthlyAmount)}/month'
                                : '${currencyFormat.format(subscription.tier.annualPrice)}/year',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Remaining books indicator
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You can borrow ${subscription.remainingBooks} more book${subscription.remainingBooks == 1 ? '' : 's'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Browse our collection and pick your next read!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Browse books button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go(RouteConstants.books),
                      icon: const Icon(Icons.search),
                      label: const Text('Browse Books'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel subscription button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _handleCancelSubscription,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cancel Subscription'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    setState(() {
      _isProcessing = true;
    });

    // Show mock payment dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _MockPaymentDialog(
        tier: _selectedTier,
        billingCycle: _selectedCycle,
      ),
    );

    if (confirmed == true && mounted) {
      final controller = ref.read(subscriptionControllerProvider.notifier);
      final success = await controller.createSubscription(
        tier: _selectedTier,
        billingCycle: _selectedCycle,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription activated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create subscription. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will lose access to borrowing books at the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Subscription'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isProcessing = true;
      });

      final controller = ref.read(subscriptionControllerProvider.notifier);
      final success = await controller.cancelSubscription();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel subscription. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TierCard extends StatelessWidget {
  final SubscriptionTier tier;
  final String price;
  final String priceLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _TierCard({
    required this.tier,
    required this.price,
    required this.priceLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<SubscriptionTier>(
                value: tier,
                groupValue: isSelected ? tier : null,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    priceLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isBold
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MockPaymentDialog extends StatefulWidget {
  final SubscriptionTier tier;
  final BillingCycle billingCycle;

  const _MockPaymentDialog({
    required this.tier,
    required this.billingCycle,
  });

  @override
  State<_MockPaymentDialog> createState() => _MockPaymentDialogState();
}

class _MockPaymentDialogState extends State<_MockPaymentDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final amount = widget.billingCycle == BillingCycle.monthly
        ? widget.tier.monthlyPrice
        : widget.tier.annualPrice;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payment),
          SizedBox(width: 8),
          Text('Complete Payment'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is a mock payment flow for testing purposes.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Plan',
                    value: widget.tier.displayName,
                  ),
                  _SummaryRow(
                    label: 'Billing',
                    value: widget.billingCycle.displayName,
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Amount',
                    value: currencyFormat.format(amount),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Pay Now'),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
