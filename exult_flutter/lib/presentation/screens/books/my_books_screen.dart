import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/presentation/providers/auth_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
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

class _MyBooksBody extends ConsumerWidget {
  const _MyBooksBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userBooksAsync = ref.watch(userBooksProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
        actions: [
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
      body: userBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_add,
                    size: 64,
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't listed any books yet",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to list your first book',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showListBookDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('List a Book'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return _UserBookCard(
                book: books[index],
                userId: currentUser?.uid ?? '',
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading your books: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userBooksProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
      // Add copy to existing book
      await ref
          .read(bookRepositoryProvider)
          .addCopyToBook(result.existingBook!.id, ref.read(currentUserProvider).valueOrNull?.uid ?? '');
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

class _UserBookCard extends ConsumerWidget {
  final Book book;
  final String userId;

  const _UserBookCard({required this.book, required this.userId});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Image
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
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

          // Book Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Author
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Deposit
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (book.isPending && isOwner) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showEditDialog(context, ref),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          color: Colors.red,
                          onPressed: () =>
                              _confirmDelete(context, ref),
                          visualDensity: VisualDensity.compact,
                        ),
                      ] else if (!book.isPending && userCopies > 0) ...[
                        TextButton.icon(
                          onPressed: () =>
                              _confirmWithdraw(context, ref),
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 18),
                          label: const Text('Withdraw'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            visualDensity: VisualDensity.compact,
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
              size: 48,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                book.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
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
        label = 'Pending';
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
