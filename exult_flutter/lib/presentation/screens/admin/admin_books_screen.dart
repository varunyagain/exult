import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exult_flutter/core/constants/route_constants.dart';
import 'package:exult_flutter/domain/models/book_model.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';
import 'package:exult_flutter/presentation/providers/books_provider.dart';
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
  String? _categoryFilter;
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
        title: const Text('Book Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.admin),
        ),
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
          // Search and Filter Bar
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
                          value: 'available', child: Text('Available')),
                      DropdownMenuItem(
                          value: 'borrowed', child: Text('Borrowed')),
                    ],
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Category Filter
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _categoryFilter,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Fiction', child: Text('Fiction')),
                      DropdownMenuItem(
                          value: 'Non-Fiction', child: Text('Non-Fiction')),
                      DropdownMenuItem(value: 'Science', child: Text('Science')),
                      DropdownMenuItem(value: 'History', child: Text('History')),
                      DropdownMenuItem(
                          value: 'Biography', child: Text('Biography')),
                    ],
                    onChanged: (value) {
                      setState(() => _categoryFilter = value);
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

      // Category filter
      if (_categoryFilter != null &&
          !book.categories.contains(_categoryFilter)) {
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
        return 4;
      case 'copies':
        return 5;
      case 'available':
        return 6;
      case 'deposit':
        return 7;
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
    final isAvailable = status == BookStatus.available;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _showBookDialog(BuildContext context, WidgetRef ref,
      {Book? book}) async {
    final isEditing = book != null;
    final result = await showDialog<Book>(
      context: context,
      builder: (context) => BookFormDialog(book: book),
    );

    if (result != null) {
      final bookRepository = ref.read(bookRepositoryProvider);
      try {
        if (isEditing) {
          await bookRepository.updateBook(result);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await bookRepository.createBook(result);
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
            SnackBar(
              content: Text('Error: $e'),
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

class BookFormDialog extends StatefulWidget {
  final Book? book;

  const BookFormDialog({super.key, this.book});

  @override
  State<BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _depositController;
  late final TextEditingController _totalCopiesController;
  late final TextEditingController _availableCopiesController;

  late BookOwnerType _ownerType;
  late BookStatus _status;
  late List<String> _selectedCategories;

  final List<String> _allCategories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Romance',
    'Mystery',
    'Technology',
    'Self-Help',
    'Children',
  ];

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');
    _coverUrlController =
        TextEditingController(text: book?.coverImageUrl ?? '');
    _depositController =
        TextEditingController(text: book?.depositAmount.toString() ?? '200');
    _totalCopiesController =
        TextEditingController(text: book?.totalCopies.toString() ?? '1');
    _availableCopiesController =
        TextEditingController(text: book?.availableCopies.toString() ?? '1');

    _ownerType = book?.ownerType ?? BookOwnerType.business;
    _status = book?.status ?? BookStatus.available;
    _selectedCategories = book?.categories.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _depositController.dispose();
    _totalCopiesController.dispose();
    _availableCopiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Author Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Author is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ISBN and Cover URL Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _coverUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Cover Image URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Deposit, Total Copies, Available Copies Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _depositController,
                        decoration: const InputDecoration(
                          labelText: 'Deposit Amount (₹) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _totalCopiesController,
                        decoration: const InputDecoration(
                          labelText: 'Total Copies *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _availableCopiesController,
                        decoration: const InputDecoration(
                          labelText: 'Available Copies *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final available = int.tryParse(value);
                          if (available == null) {
                            return 'Invalid number';
                          }
                          final total =
                              int.tryParse(_totalCopiesController.text) ?? 0;
                          if (available > total) {
                            return 'Cannot exceed total';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Owner Type and Status Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BookOwnerType>(
                        value: _ownerType,
                        decoration: const InputDecoration(
                          labelText: 'Owner Type',
                          border: OutlineInputBorder(),
                        ),
                        items: BookOwnerType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type == BookOwnerType.business
                                ? 'Business'
                                : 'Community'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _ownerType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<BookStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: BookStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Add Book'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImageUrl: _coverUrlController.text.trim().isEmpty
            ? null
            : _coverUrlController.text.trim(),
        ownerType: _ownerType,
        categories: _selectedCategories,
        depositAmount: double.parse(_depositController.text),
        status: _status,
        totalCopies: int.parse(_totalCopiesController.text),
        availableCopies: int.parse(_availableCopiesController.text),
        createdAt: widget.book?.createdAt ?? DateTime.now(),
      );

      Navigator.of(context).pop(book);
    }
  }
}
