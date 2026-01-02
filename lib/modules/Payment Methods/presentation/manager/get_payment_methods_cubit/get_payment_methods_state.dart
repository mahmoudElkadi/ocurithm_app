part of 'get_payment_methods_cubit.dart';

/// State for GetPaymentMethodsCubit
class GetPaymentMethodsState {
  final PaymentMethodsModel? paymentMethods;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final String searchQuery;
  final bool hasReachedMax;

  const GetPaymentMethodsState({
    this.paymentMethods,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.searchQuery = '',
    this.hasReachedMax = false,
  });

  GetPaymentMethodsState copyWith({
    PaymentMethodsModel? paymentMethods,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    String? searchQuery,
    bool? hasReachedMax,
  }) {
    return GetPaymentMethodsState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
