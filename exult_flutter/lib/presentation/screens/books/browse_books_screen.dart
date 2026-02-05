import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/providers/subscription_provider.dart';
import 'package:exult_flutter/presentation/widgets/cards/book_card.dart';

class BrowseBooksScreen extends ConsumerStatefulWidget {
  const BrowseBooksScreen({super.key});

  @override
  ConsumerState<BrowseBooksScreen> createState() => _BrowseBooksScreenState();
}

class _BrowseBooksScreenState extends ConsumerState<BrowseBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final availableBooks = ref.watch(availableBooksProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Browse Books'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          if (isAdmin)
            TextButton.icon(
              onPressed: () => context.go(RouteConstants.admin),
              icon: const Icon(Icons.admin_panel_settings, size: 18),
              label: const Text('Admin'),
            ),
          TextButton(
            onPressed: () => context.go(RouteConstants.loans),
            child: const Text('My Loans'),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.profile),
            child: const Text('Profile'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RouteConstants.home);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }

          final activeSubscription = ref.watch(activeSubscriptionProvider);

          return Column(
            children: [
              // Subscription Status Banner
              activeSubscription.when(
                data: (subscription) {
                  if (subscription == null) {
                    return _buildNoSubscriptionBanner(context);
                  }
                  return _buildSubscriptionStatusBanner(context, subscription);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Category Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        context,
                        label: 'All Books',
                        category: null,
                        isSelected: selectedCategory == null,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        label: 'Fiction',
                        category: 'Fiction',
                        isSelected: selectedCategory == 'Fiction',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        label: 'Non-Fiction',
                        category: 'Non-Fiction',
                        isSelected: selectedCategory == 'Non-Fiction',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        label: 'Science',
                        category: 'Science',
                        isSelected: selectedCategory == 'Science',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        label: 'History',
                        category: 'History',
                        isSelected: selectedCategory == 'History',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        context,
                        label: 'Biography',
                        category: 'Biography',
                        isSelected: selectedCategory == 'Biography',
                      ),
                    ],
                  ),
                ),
              ),

              // Books Grid
              Expanded(
                child: availableBooks.when(
                  data: (books) {
                    if (books.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              size: 64,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No books available',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new arrivals',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter books by search query if searching
                    final displayBooks = _isSearching && _searchController.text.isNotEmpty
                        ? books.where((book) {
                            final query = _searchController.text.toLowerCase();
                            return book.title.toLowerCase().contains(query) ||
                                book.author.toLowerCase().contains(query);
                          }).toList()
                        : books;

                    if (displayBooks.isEmpty && _isSearching) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No books found',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: displayBooks.length,
                      itemBuilder: (context, index) {
                        return BookCard(book: displayBooks[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading books',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required String? category,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(categoryFilterProvider.notifier).setCategory(category);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildNoSubscriptionBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Subscription',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subscribe to start borrowing books',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.go(RouteConstants.subscribe),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusBanner(
    BuildContext context,
    dynamic subscription,
  ) {
    final canBorrow = subscription.canBorrowMore;
    final remaining = subscription.remainingBooks;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canBorrow
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canBorrow
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canBorrow ? Icons.check_circle : Icons.warning_amber_rounded,
            color: canBorrow ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.tier.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  canBorrow
                      ? 'You can borrow $remaining more book${remaining == 1 ? '' : 's'}'
                      : 'Return a book to borrow more',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go(RouteConstants.subscribe),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}
