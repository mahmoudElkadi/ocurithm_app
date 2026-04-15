part of 'product_actions_cubit.dart';

enum ProductActionsStatus { initial, loading, success, error }

class ProductActionsState {
  final ProductActionsStatus status;
  final String? errorMessage;
  final String? successMessage;
  final Product? product;

  final String? actingId;

  const ProductActionsState({
    this.status = ProductActionsStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.product,
    this.actingId,
  });

  bool get isLoading => status == ProductActionsStatus.loading;
  bool get isSuccess => status == ProductActionsStatus.success;
  bool get isError => status == ProductActionsStatus.error;

  ProductActionsState copyWith({
    ProductActionsStatus? status,
    String? errorMessage,
    String? successMessage,
    Product? product,
    String? actingId,
  }) {
    return ProductActionsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      product: product ?? this.product,
      actingId: actingId ?? this.actingId,
    );
  }
}
