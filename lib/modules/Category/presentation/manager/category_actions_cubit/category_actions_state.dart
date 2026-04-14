part of 'category_actions_cubit.dart';

enum CategoryActionsStatus { initial, loading, success, error, noConnection }

enum CategoryActionType { none, add, update, delete }

class CategoryActionsState {
  final CategoryActionsStatus status;
  final CategoryActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final Category? category;

  const CategoryActionsState({
    this.status = CategoryActionsStatus.initial,
    this.actionType = CategoryActionType.none,
    this.errorMessage,
    this.successMessage,
    this.category,
  });

  bool get isLoading => status == CategoryActionsStatus.loading;
  bool get isSuccess => status == CategoryActionsStatus.success;
  bool get isError => status == CategoryActionsStatus.error;
  bool get noConnection => status == CategoryActionsStatus.noConnection;

  bool get isAddSuccess => isSuccess && actionType == CategoryActionType.add;
  bool get isUpdateSuccess => isSuccess && actionType == CategoryActionType.update;
  bool get isDeleteSuccess => isSuccess && actionType == CategoryActionType.delete;

  CategoryActionsState copyWith({
    CategoryActionsStatus? status,
    CategoryActionType? actionType,
    String? errorMessage,
    String? successMessage,
    Category? category,
  }) {
    return CategoryActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      category: category ?? this.category,
    );
  }
}
