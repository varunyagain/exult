import 'package:flutter/material.dart';
import 'package:exult_flutter/core/constants/category_tree.dart';

/// Tri-state for a category node's selection.
enum _CheckState { none, some, all }

/// A collapsible category tree with tri-state checkboxes.
/// Only shows categories that have at least one book.
class CategoryTreeWidget extends StatefulWidget {
  /// Set of all category names present across books in the catalog.
  final Set<String> categoriesWithBooks;

  /// Currently selected category names (leaf or any level).
  final Set<String> selectedCategories;

  /// Called whenever the selection changes.
  final ValueChanged<Set<String>> onSelectionChanged;

  const CategoryTreeWidget({
    super.key,
    required this.categoriesWithBooks,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<CategoryTreeWidget> createState() => _CategoryTreeWidgetState();
}

class _CategoryTreeWidgetState extends State<CategoryTreeWidget> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final visibleRoots = ecorfanCategoryTree
        .where((node) => _hasBooks(node))
        .toList();

    if (visibleRoots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No categories available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Icon(Icons.category, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (widget.selectedCategories.isNotEmpty)
                TextButton(
                  onPressed: () => widget.onSelectionChanged({}),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: visibleRoots
                .map((node) => _buildNode(context, node, 0))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Check if a node or any of its descendants has books.
  bool _hasBooks(CategoryNode node) {
    if (widget.categoriesWithBooks.contains(node.name)) return true;
    return node.children.any((child) => _hasBooks(child));
  }

  /// Compute the check state for a node.
  _CheckState _checkState(CategoryNode node) {
    if (node.children.isEmpty) {
      // Leaf node
      return widget.selectedCategories.contains(node.name)
          ? _CheckState.all
          : _CheckState.none;
    }

    // Non-leaf: check visible children
    final visibleChildren = node.children.where((c) => _hasBooks(c)).toList();
    if (visibleChildren.isEmpty) {
      return widget.selectedCategories.contains(node.name)
          ? _CheckState.all
          : _CheckState.none;
    }

    final childStates = visibleChildren.map((c) => _checkState(c)).toList();
    if (childStates.every((s) => s == _CheckState.all)) return _CheckState.all;
    if (childStates.every((s) => s == _CheckState.none)) return _CheckState.none;
    return _CheckState.some;
  }

  /// Get all selectable category names under a node (only those with books).
  Set<String> _selectableNames(CategoryNode node) {
    final result = <String>{};
    if (widget.categoriesWithBooks.contains(node.name)) {
      result.add(node.name);
    }
    for (final child in node.children) {
      if (_hasBooks(child)) {
        result.addAll(_selectableNames(child));
      }
    }
    return result;
  }

  void _onNodeTap(CategoryNode node) {
    final state = _checkState(node);
    final names = _selectableNames(node);
    final newSelection = Set<String>.from(widget.selectedCategories);

    if (state == _CheckState.all) {
      // Deselect all
      newSelection.removeAll(names);
    } else {
      // Select all
      newSelection.addAll(names);
    }

    widget.onSelectionChanged(newSelection);
  }

  Widget _buildNode(BuildContext context, CategoryNode node, int depth) {
    if (!_hasBooks(node)) return const SizedBox.shrink();

    final visibleChildren =
        node.children.where((c) => _hasBooks(c)).toList();
    final hasChildren = visibleChildren.isNotEmpty;
    final isExpanded = _expanded.contains(node.name);
    final state = _checkState(node);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _onNodeTap(node),
          child: Padding(
            padding: EdgeInsets.only(
              left: 8.0 + depth * 20.0,
              right: 8,
              top: 4,
              bottom: 4,
            ),
            child: Row(
              children: [
                // Expand/collapse toggle
                if (hasChildren)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expanded.remove(node.name);
                        } else {
                          _expanded.add(node.name);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isExpanded
                            ? Icons.expand_more
                            : Icons.chevron_right,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 22),

                const SizedBox(width: 4),

                // Tri-state checkbox
                _TriStateCheckbox(state: state),

                const SizedBox(width: 8),

                // Label
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: depth == 0 ? 13 : 12,
                      fontWeight:
                          depth == 0 ? FontWeight.w600 : FontWeight.normal,
                      color: state != _CheckState.none
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children (if expanded)
        if (hasChildren && isExpanded)
          ...visibleChildren
              .map((child) => _buildNode(context, child, depth + 1)),
      ],
    );
  }
}

class _TriStateCheckbox extends StatelessWidget {
  final _CheckState state;

  const _TriStateCheckbox({required this.state});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    switch (state) {
      case _CheckState.none:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      case _CheckState.some:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.3),
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Center(
            child: Icon(Icons.remove, size: 14, color: Colors.white),
          ),
        );
      case _CheckState.all:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor,
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 14, color: Colors.white),
          ),
        );
    }
  }
}
