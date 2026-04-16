part of 'supplier_actions_cubit.dart';

enum SupplierActionsStatus { initial, loading, success, error }

class SupplierActionsState {
  final SupplierActionsStatus status;
  final String? successMessage;
  final String? errorMessage;
  final Supplier? supplier;
  final String? actingId;

  const SupplierActionsState({
    this.status = SupplierActionsStatus.initial,
    this.successMessage,
    this.errorMessage,
    this.supplier,
    this.actingId,
  });

  bool get isLoading => status == SupplierActionsStatus.loading;
  bool get isSuccess => status == SupplierActionsStatus.success;
  bool get isError => status == SupplierActionsStatus.error;

  SupplierActionsState copyWith({
    SupplierActionsStatus? status,
    String? successMessage,
    String? errorMessage,
    Supplier? supplier,
    String? actingId,
  }) {
    return SupplierActionsState(
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      supplier: supplier ?? this.supplier,
      actingId: actingId ?? this.actingId,
    );
  }
}
