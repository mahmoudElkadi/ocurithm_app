part of 'get_single_product_cubit.dart';

enum GetSingleProductStatus { initial, loading, success, error }

class GetSingleProductState {
  final GetSingleProductStatus status;
  final Product? product;
  final String? errorMessage;

  const GetSingleProductState({
    this.status = GetSingleProductStatus.initial,
    this.product,
    this.errorMessage,
  });

  bool get isLoading => status == GetSingleProductStatus.loading;
  bool get isSuccess => status == GetSingleProductStatus.success;
  bool get isError => status == GetSingleProductStatus.error;

  GetSingleProductState copyWith({
    GetSingleProductStatus? status,
    Product? product,
    String? errorMessage,
  }) {
    return GetSingleProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
