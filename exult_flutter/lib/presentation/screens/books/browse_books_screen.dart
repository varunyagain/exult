import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
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

          return Column(
            children: [
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
}
