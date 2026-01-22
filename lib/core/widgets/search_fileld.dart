import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/widgets/text_field.dart';

class SearchField extends StatefulWidget {
  const SearchField(
      {super.key,
      required this.onTextFieldChanged,
      required this.searchController,
      required this.onClose});
  final Future<void> Function() onTextFieldChanged;
  final TextEditingController searchController;
  final Function() onClose;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
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

      operation = CancelableOperation.fromFuture(
        widget.onTextFieldChanged(),
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
      ).copyWith(bottom: 10, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField2(
              controller: widget.searchController,
              hintText: "Search...",
              hintStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              height: 7,
              fillColor: Theme.of(context).primaryColor.withValues(alpha:0.03),
              radius: 30,
              isShadow: false,
              borderColor: Theme.of(context).primaryColor,
              prefixIcon: Icon(
                Icons.search,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
              onTextFieldChanged: (value) {
                searchItem();
              },
              suffixIcon: IconButton(
                onPressed: widget.onClose,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              required: false,
            ),
          ),
        ],
      ),
    );
  }
}
