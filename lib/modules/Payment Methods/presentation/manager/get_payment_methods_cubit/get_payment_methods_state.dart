part of 'get_payment_methods_cubit.dart';

enum GetPaymentMethodsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore,
}

extension GetPaymentMethodsStatusX on GetPaymentMethodsState {
  bool get isInitial => state == GetPaymentMethodsStatus.initial;
  bool get isLoading => state == GetPaymentMethodsStatus.loading;
  bool get isLoadingMore => state == GetPaymentMethodsStatus.loadingMore;
  bool get isSuccess => state == GetPaymentMethodsStatus.success;
  bool get isError => state == GetPaymentMethodsStatus.error;
  bool get noConnection => state == GetPaymentMethodsStatus.noConnection;
}

/// State for GetPaymentMethodsCubit
class GetPaymentMethodsState {
  final GetPaymentMethodsStatus state;
  final PaymentMethodsModel? paymentMethods;
  final String? errorMessage;
  final int currentPage;
  final String searchQuery;
  final bool hasReachedMax;
  final String? clinicFilter;

  const GetPaymentMethodsState({
    this.state = GetPaymentMethodsStatus.initial,
    this.paymentMethods,
    this.errorMessage,
    this.currentPage = 1,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.clinicFilter,
  });

  GetPaymentMethodsState copyWith({
    GetPaymentMethodsStatus? state,
    PaymentMethodsModel? paymentMethods,
    String? errorMessage,
    int? currentPage,
    String? searchQuery,
    bool? hasReachedMax,
    String? clinicFilter,
  }) {
    return GetPaymentMethodsState(
      state: state ?? this.state,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      clinicFilter: clinicFilter ?? this.clinicFilter,
    );
  }
}
