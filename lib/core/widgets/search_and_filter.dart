import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

class SearchAndFilter extends StatefulWidget {
  const SearchAndFilter(
      {super.key,
      this.hintText = 'Search...',
      this.isFiltered = true,
      this.withShadow = false,
      this.onTap,
      required this.onChanged,
      this.controller,
      this.paddingValue,
      this.radius = 24,
      this.backgroundColor = const Color(0xFFF5F5F5)});

  final String hintText;
  final bool isFiltered;
  final bool withShadow;
  final VoidCallback? onTap;

  // Changed to support both sync and async functions
  final Function() onChanged;
  final TextEditingController? controller;
  final double? paddingValue;
  final double radius;
  final Color backgroundColor;

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  @override
  dispose() {
    _searchDebounceTimer?.cancel();
    for (var operation in _operations) {
      operation.cancel();
    }
    _operations.clear();
    super.dispose();
  }

  Timer? _searchDebounceTimer;
  List<CancelableOperation<void>> _operations = [];

  void searchItem() async {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Cancel all previous operations
    for (var operation in _operations) {
      await operation.cancel();
    }
    _operations.clear();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 750), () async {
      // Create new cancelable operation
      late final CancelableOperation<void> operation;

      // Fixed: Handle both sync and async onChanged callbacks
      operation = CancelableOperation.fromFuture(
        Future(() async {
          final result = widget.onChanged();
          // If result is a Future, await it; otherwise, it's already complete
          if (result is Future) {
            await result;
          }
        }),
        onCancel: () {
          _operations.remove(operation);
        },
      );

      // Add to operations list
      _operations.add(operation);

      try {
        // Execute the operation
        await operation.value;
        print('Search completed');
        // Remove completed operation
        _operations.remove(operation);
      } catch (error) {
        print('Search error: $error');
        _operations.remove(operation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: widget.withShadow
                    ? [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    onChanged: (_) {
                      searchItem();
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                widget.controller != null && widget.controller!.text.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          widget.controller!.clear();
                          widget.onChanged();
                        },
                        child: const Icon(Icons.close, color: Colors.black))
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        if (widget.isFiltered) ...[
          const SizedBox(width: 12),
          InkWell(
            onTap: widget.onTap,
            child: Ink(
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.tune, color: Colors.grey),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
