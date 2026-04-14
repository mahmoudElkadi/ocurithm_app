part of 'sub_category_actions_cubit.dart';

enum SubCategoryActionsStatus { initial, loading, success, error, noConnection }

enum SubCategoryActionType { none, add, update, delete }

class SubCategoryActionsState {
  final SubCategoryActionsStatus status;
  final SubCategoryActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final SubCategory? subCategory;

  const SubCategoryActionsState({
    this.status = SubCategoryActionsStatus.initial,
    this.actionType = SubCategoryActionType.none,
    this.errorMessage,
    this.successMessage,
    this.subCategory,
  });

  bool get isLoading => status == SubCategoryActionsStatus.loading;
  bool get isSuccess => status == SubCategoryActionsStatus.success;
  bool get isError => status == SubCategoryActionsStatus.error;

  SubCategoryActionsState copyWith({
    SubCategoryActionsStatus? status,
    SubCategoryActionType? actionType,
    String? errorMessage,
    String? successMessage,
    SubCategory? subCategory,
  }) {
    return SubCategoryActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      subCategory: subCategory ?? this.subCategory,
    );
  }
}
