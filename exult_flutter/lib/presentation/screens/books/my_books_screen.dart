import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/core/constants/genre_tree.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/widgets/attribute_tree_widget.dart';
import 'package:exult_flutter/presentation/widgets/book_form_dialog.dart';

class MyBooksScreen extends ConsumerWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Books')),
            body: const Center(child: Text('Please sign in')),
          );
        }
        return const _MyBooksBody();
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('My Books')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('My Books')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MyBooksBody extends ConsumerStatefulWidget {
  const _MyBooksBody();

  @override
  ConsumerState<_MyBooksBody> createState() => _MyBooksBodyState();
}

class _MyBooksBodyState extends ConsumerState<_MyBooksBody> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _categoriesInitialized = false;
  bool _genresInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBooksAsync = ref.watch(userBooksProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final selectedCategories = ref.watch(selectedMyBooksCategoriesProvider);
    final categoriesWithBooks = ref.watch(userBookCategoriesProvider);
    final selectedGenres = ref.watch(selectedMyBooksGenresProvider);
    final genresWithBooks = ref.watch(userBookGenresProvider);

    // Auto-select all attribute values on first load
    if (!_categoriesInitialized && categoriesWithBooks.isNotEmpty) {
      _categoriesInitialized = true;
      if (selectedCategories.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedMyBooksCategoriesProvider.notifier).state =
              Set.from(categoriesWithBooks);
        });
      }
    }
    if (!_genresInitialized && genresWithBooks.isNotEmpty) {
      _genresInitialized = true;
      if (selectedGenres.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedMyBooksGenresProvider.notifier).state =
              Set.from(genresWithBooks);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search my books...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => setState(() {}),
              )
            : const Text('My Books'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.books),
            child: const Text('Browse Books'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showListBookDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('List a Book'),
      ),
      body: Row(
        children: [
          // Filter sidebar
          Container(
            width: 240,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                // Category tree
                Expanded(
                  child: AttributeTreeWidget(
                    availableValues: categoriesWithBooks,
                    selectedValues: selectedCategories,
                    onSelectionChanged: (newSelection) {
                      ref.read(selectedMyBooksCategoriesProvider.notifier).state =
                          newSelection;
                    },
                  ),
                ),
                const Divider(height: 1),
                // Genre tree
                Expanded(
                  child: AttributeTreeWidget(
                    treeData: writingGenreTree,
                    title: 'Genres',
                    icon: Icons.auto_stories,
                    availableValues: genresWithBooks,
                    selectedValues: selectedGenres,
                    onSelectionChanged: (newSelection) {
                      ref.read(selectedMyBooksGenresProvider.notifier).state =
                          newSelection;
                    },
                  ),
                ),
              ],
            ),
          ),

          // Books Grid
          Expanded(
            child: userBooksAsync.when(
              data: (books) {
                // Apply category filter
                var filteredBooks = books;
                if (selectedCategories.isNotEmpty) {
                  filteredBooks = filteredBooks.where((book) {
                    return book.categories
                        .any((cat) => selectedCategories.contains(cat));
                  }).toList();
                }

                // Apply genre filter
                if (selectedGenres.isNotEmpty) {
                  filteredBooks = filteredBooks.where((book) {
                    return book.genres
                        .any((g) => selectedGenres.contains(g));
                  }).toList();
                }

                // Apply search filter
                if (_isSearching && _searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  filteredBooks = filteredBooks.where((book) {
                    return book.title.toLowerCase().contains(query) ||
                        book.author.toLowerCase().contains(query);
                  }).toList();
                }

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          books.isEmpty
                              ? Icons.library_add
                              : (_isSearching
                                  ? Icons.search_off
                                  : Icons.library_books_outlined),
                          size: 64,
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          books.isEmpty
                              ? "You haven't listed any books yet"
                              : (_isSearching
                                  ? 'No books found'
                                  : 'No books match selected filters'),
                          style:
                              Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          books.isEmpty
                              ? 'Tap the + button to list your first book'
                              : (_isSearching
                                  ? 'Try a different search term'
                                  : 'Try selecting different filters'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                        ),
                        if (books.isEmpty) ...[
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () =>
                                _showListBookDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('List a Book'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.42,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    return _MyBookCard(
                      book: filteredBooks[index],
                      userId: currentUser?.uid ?? '',
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading your books',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(userBooksProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showListBookDialog(BuildContext context, WidgetRef ref) async {
    final bookRepository = ref.read(bookRepositoryProvider);

    final result = await showDialog<BookFormResult>(
      context: context,
      builder: (context) => BookFormDialog(
        isUserMode: true,
        onIsbnLookup: (isbn) => bookRepository.findBookByIsbn(isbn),
      ),
    );

    if (result == null) return;

    final controller = ref.read(userBookControllerProvider.notifier);

    if (result.isDuplicate && result.existingBook != null) {
      await ref
          .read(bookRepositoryProvider)
          .addCopyToBook(result.existingBook!.id,
              ref.read(currentUserProvider).valueOrNull?.uid ?? '');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Your copy was added to "${result.existingBook!.title}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (result.book != null) {
      final wasDuplicate = await controller.listBook(result.book!);
      if (context.mounted) {
        if (wasDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your copy was added to an existing book'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Book listed successfully! It will appear in the catalog after admin approval.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
    ref.invalidate(userBooksProvider);
  }
}

/// Book card for My Books — matches Browse Books card style with user actions.
class _MyBookCard extends ConsumerWidget {
  final Book book;
  final String userId;

  const _MyBookCard({required this.book, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    final userCopies = book.contributors[userId] ?? 0;
    final isOwner = book.ownerId == userId;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('${RouteConstants.books}/${book.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Image with status badge overlay
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    book.coverImageUrl != null &&
                            book.coverImageUrl!.isNotEmpty
                        ? Image.network(
                            book.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderCover(context);
                            },
                          )
                        : _buildPlaceholderCover(context),
                    // Status badge overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(context),
                    ),
                  ],
                ),
              ),
            ),

            // Book Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Author
                    Text(
                      book.author,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Copies info
                    Row(
                      children: [
                        Icon(
                          Icons.content_copy,
                          size: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your copies: $userCopies',
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
                    const SizedBox(height: 4),

                    // Deposit Amount
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deposit: ${currencyFormat.format(book.depositAmount)}',
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
                    const SizedBox(height: 4),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (book.isPending && isOwner) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: 'Edit',
                            onPressed: () =>
                                _showEditDialog(context, ref),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            tooltip: 'Delete',
                            color: Colors.red,
                            onPressed: () =>
                                _confirmDelete(context, ref),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ] else if (!book.isPending &&
                            userCopies > 0) ...[
                          TextButton.icon(
                            onPressed: () =>
                                _confirmWithdraw(context, ref),
                            icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 16),
                            label: const Text('Withdraw',
                                style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                book.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (book.status) {
      case BookStatus.pending:
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        label = 'Pending Approval';
        icon = Icons.hourglass_top;
        break;
      case BookStatus.available:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Available';
        icon = Icons.check_circle;
        break;
      case BookStatus.borrowed:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Borrowed';
        icon = Icons.menu_book;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final bookRepository = ref.read(bookRepositoryProvider);
    final result = await showDialog<BookFormResult>(
      context: context,
      builder: (context) => BookFormDialog(
        book: book,
        isUserMode: true,
        onIsbnLookup: (isbn) => bookRepository.findBookByIsbn(isbn),
      ),
    );

    if (result != null && result.book != null) {
      final controller = ref.read(userBookControllerProvider.notifier);
      await controller.updateMyBook(result.book!);
      ref.invalidate(userBooksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ref.read(userBookControllerProvider.notifier);
      await controller.withdrawCopy(book);
      ref.invalidate(userBooksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Copy'),
        content: Text(
          'Are you sure you want to withdraw your copy of "${book.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ref.read(userBookControllerProvider.notifier);
      await controller.withdrawCopy(book);
      ref.invalidate(userBooksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copy withdrawn successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
