import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/core/constants/genre_tree.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
import 'package:exult_flutter/presentation/widgets/attribute_tree_widget.dart';
import 'package:exult_flutter/presentation/widgets/book_form_dialog.dart' as shared;
import 'package:intl/intl.dart';

class AdminBooksScreen extends ConsumerStatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  ConsumerState<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends ConsumerState<AdminBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;
  Set<String> _selectedTreeCategories = {};
  Set<String> _selectedTreeGenres = {};
  String _sortColumn = 'title';
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allBooksAsync = ref.watch(allBooksProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.books);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(allBooksProvider),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showBookDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
              children: [
                // Search and Status Filter Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search Field
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by title, author, or ISBN...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value.toLowerCase());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Category Filter
                      SizedBox(
                        width: 200,
                        child: InkWell(
                          onTap: () async {
                            final bookCategories =
                                ref.read(allBookCategoriesAdminProvider);
                            final result = await showDialog<Set<String>>(
                              context: context,
                              builder: (_) => AttributePickerDialog(
                                initialSelection:
                                    _selectedTreeCategories.isEmpty
                                        ? bookCategories
                                        : _selectedTreeCategories,
                                allNames: bookCategories,
                              ),
                            );
                            if (result != null) {
                              setState(() => _selectedTreeCategories = result);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Categories',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            child: Text(
                              _selectedTreeCategories.isEmpty
                                  ? 'All'
                                  : '${_selectedTreeCategories.length} selected',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Genre Filter
                      SizedBox(
                        width: 200,
                        child: InkWell(
                          onTap: () async {
                            final bookGenres =
                                ref.read(allBookGenresAdminProvider);
                            final result = await showDialog<Set<String>>(
                              context: context,
                              builder: (_) => AttributePickerDialog(
                                initialSelection:
                                    _selectedTreeGenres.isEmpty
                                        ? bookGenres
                                        : _selectedTreeGenres,
                                treeData: writingGenreTree,
                                allNames: bookGenres,
                                title: 'Select Genres',
                                icon: Icons.auto_stories,
                              ),
                            );
                            if (result != null) {
                              setState(() => _selectedTreeGenres = result);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Genres',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            child: Text(
                              _selectedTreeGenres.isEmpty
                                  ? 'All'
                                  : '${_selectedTreeGenres.length} selected',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Status Filter
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(
                                value: 'pending', child: Text('Pending Approval')),
                            DropdownMenuItem(
                                value: 'available', child: Text('Available')),
                            DropdownMenuItem(
                                value: 'borrowed', child: Text('Borrowed')),
                          ],
                          onChanged: (value) {
                            setState(() => _statusFilter = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Table
                Expanded(
                  child: allBooksAsync.when(
                    data: (books) {
                      final filteredBooks = _filterAndSortBooks(books);

                      if (filteredBooks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                books.isEmpty
                                    ? 'No books in catalog'
                                    : 'No books match your filters',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (books.isEmpty) ...[
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () => _showBookDialog(context, ref),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First Book'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildDataTable(context, ref, filteredBooks),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(allBooksProvider),
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

  List<Book> _filterAndSortBooks(List<Book> books) {
    var filtered = books.where((book) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = book.title.toLowerCase().contains(_searchQuery) ||
            book.author.toLowerCase().contains(_searchQuery) ||
            (book.isbn?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_statusFilter != null && book.status.name != _statusFilter) {
        return false;
      }

      // Category filter (tree-based)
      if (_selectedTreeCategories.isNotEmpty &&
          !book.categories.any((cat) => _selectedTreeCategories.contains(cat))) {
        return false;
      }

      // Genre filter (tree-based)
      if (_selectedTreeGenres.isNotEmpty &&
          !book.genres.any((g) => _selectedTreeGenres.contains(g))) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'author':
          comparison = a.author.compareTo(b.author);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'copies':
          comparison = a.totalCopies.compareTo(b.totalCopies);
          break;
        case 'available':
          comparison = a.availableCopies.compareTo(b.availableCopies);
          break;
        case 'deposit':
          comparison = a.depositAmount.compareTo(b.depositAmount);
          break;
        default:
          comparison = a.title.compareTo(b.title);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildDataTable(
      BuildContext context, WidgetRef ref, List<Book> books) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return DataTable(
      sortColumnIndex: _getSortColumnIndex(),
      sortAscending: _sortAscending,
      headingRowColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      columns: [
        DataColumn(
          label: const Text('Title'),
          onSort: (_, ascending) => _onSort('title', ascending),
        ),
        DataColumn(
          label: const Text('Author'),
          onSort: (_, ascending) => _onSort('author', ascending),
        ),
        const DataColumn(label: Text('ISBN')),
        const DataColumn(label: Text('Categories')),
        const DataColumn(label: Text('Genres')),
        DataColumn(
          label: const Text('Status'),
          onSort: (_, ascending) => _onSort('status', ascending),
        ),
        DataColumn(
          label: const Text('Total Copies'),
          numeric: true,
          onSort: (_, ascending) => _onSort('copies', ascending),
        ),
        DataColumn(
          label: const Text('Available'),
          numeric: true,
          onSort: (_, ascending) => _onSort('available', ascending),
        ),
        DataColumn(
          label: const Text('Deposit'),
          numeric: true,
          onSort: (_, ascending) => _onSort('deposit', ascending),
        ),
        const DataColumn(label: Text('Owner')),
        const DataColumn(label: Text('Actions')),
      ],
      rows: books.map((book) {
        return DataRow(
          cells: [
            DataCell(
              SizedBox(
                width: 200,
                child: Text(
                  book.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: Text(
                  book.author,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text(book.isbn ?? '-')),
            DataCell(
              SizedBox(
                width: 150,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: book.categories.take(2).map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: book.genres.take(2).map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            DataCell(_buildStatusBadge(context, book.status)),
            DataCell(Text('${book.totalCopies}')),
            DataCell(
              Text(
                '${book.availableCopies}',
                style: TextStyle(
                  color: book.availableCopies == 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(Text(currencyFormat.format(book.depositAmount))),
            DataCell(
              Text(
                book.ownerType == BookOwnerType.business
                    ? 'Business'
                    : 'Community',
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (book.isPending) ...[
                    IconButton(
                      icon: const Icon(Icons.check_circle, size: 20),
                      tooltip: 'Approve',
                      color: Colors.green,
                      onPressed: () => _approveBook(context, ref, book),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      tooltip: 'Reject',
                      color: Colors.red,
                      onPressed: () => _confirmDelete(context, ref, book),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit',
                    onPressed: () => _showBookDialog(context, ref, book: book),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Delete',
                    color: Colors.red,
                    onPressed: () => _confirmDelete(context, ref, book),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'title':
        return 0;
      case 'author':
        return 1;
      case 'status':
        return 5;
      case 'copies':
        return 6;
      case 'available':
        return 7;
      case 'deposit':
        return 8;
      default:
        return 0;
    }
  }

  void _onSort(String column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _sortAscending = ascending;
    });
  }

  Widget _buildStatusBadge(BuildContext context, BookStatus status) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (status) {
      case BookStatus.pending:
        bgColor = Colors.amber.shade50;
        borderColor = Colors.amber.shade200;
        textColor = Colors.amber.shade800;
        break;
      case BookStatus.available:
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        textColor = Colors.green.shade700;
        break;
      case BookStatus.borrowed:
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade200;
        textColor = Colors.orange.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _showBookDialog(BuildContext context, WidgetRef ref,
      {Book? book}) async {
    final isEditing = book != null;
    final bookRepository = ref.read(bookRepositoryProvider);

    if (isEditing) {
      // Edit flow — no ISBN lookup, returns Book directly
      final result = await showDialog<Book>(
        context: context,
        builder: (context) => shared.BookFormDialog(book: book),
      );
      if (result == null) return;
      try {
        await bookRepository.updateBook(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        ref.invalidate(allBooksProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Add flow — ISBN lookup enabled, returns BookFormResult
      final result = await showDialog<shared.BookFormResult>(
        context: context,
        builder: (context) => shared.BookFormDialog(
          onIsbnLookup: (isbn) => bookRepository.findBookByIsbn(isbn),
        ),
      );
      if (result == null) return;
      try {
        if (result.isDuplicate && result.existingBook != null) {
          // Increment copy count on existing book
          await bookRepository.addCopyToBook(result.existingBook!.id, '');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Added a copy to "${result.existingBook!.title}"'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (result.book != null) {
          await bookRepository.createBook(result.book!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        ref.invalidate(allBooksProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _approveBook(
      BuildContext context, WidgetRef ref, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Book'),
        content: Text(
          'Approve "${book.title}" by ${book.author}? It will become visible in the catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final bookRepository = ref.read(bookRepositoryProvider);
        await bookRepository.approveBook(book.id);
        ref.invalidate(allBooksProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error approving book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Book book) async {
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
      try {
        final bookRepository = ref.read(bookRepositoryProvider);
        await bookRepository.deleteBook(book.id);
        ref.invalidate(allBooksProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

