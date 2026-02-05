import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/model/payment_method_model.dart';
import '../../../data/repos/payment_method_repo.dart';

part 'get_payment_methods_event.dart';
part 'get_payment_methods_state.dart';

/// Cubit for fetching payment methods with pagination and search
class GetPaymentMethodsCubit
    extends Bloc<GetPaymentMethodsEvent, GetPaymentMethodsState> {
  final PaymentMethodRepo paymentMethodRepo;

  // Debounce controller for search
  final _searchSubject = BehaviorSubject<String>();
  StreamSubscription? _searchSubscription;

  GetPaymentMethodsCubit(this.paymentMethodRepo)
      : super(const GetPaymentMethodsState()) {
    // Register event handlers
    on<GetAllPaymentMethodsEvent>(_onGetAllPaymentMethods);
    on<LoadMorePaymentMethodsEvent>(_onLoadMorePaymentMethods);
    on<SetSearchEvent>(_onSetSearch);
    on<SearchPaymentMethodsEvent>(_onSearchPaymentMethods);

    // Setup debounced search
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen((query) {
      add(SearchPaymentMethodsEvent(query));
    });
  }

  /// Handle search query changes with debounce
  void onSearchChanged(String query) {
    _searchSubject.add(query);
    add(SetSearchEvent(query));
  }

  /// Fetch all payment methods (first page)
  Future<void> _onGetAllPaymentMethods(
    GetAllPaymentMethodsEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Fetch payment methods
      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: event.noPagination ? null : 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      if (result.error == null && result.paymentMethods != null) {
        emit(state.copyWith(
          isLoading: false,
          paymentMethods: result,
          currentPage: 1,
          hasReachedMax: result.paymentMethods!.isEmpty,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to load payment methods',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Load more payment methods (next page)
  Future<void> _onLoadMorePaymentMethods(
    LoadMorePaymentMethodsEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: nextPage,
        search: state.searchQuery,
      );

      if (result.error == null && result.paymentMethods != null) {
        // Merge new payment methods with existing ones
        final updatedPaymentMethods =
            state.paymentMethods?.paymentMethods ?? [];
        updatedPaymentMethods.addAll(result.paymentMethods!);

        emit(state.copyWith(
          isLoadingMore: false,
          currentPage: nextPage,
          hasReachedMax: result.paymentMethods!.isEmpty,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Set search query (doesn't trigger search immediately)
  void _onSetSearch(
    SetSearchEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Search payment methods (triggered after debounce)
  Future<void> _onSearchPaymentMethods(
    SearchPaymentMethodsEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: 1,
        search: event.query,
      );

      if (result.error == null && result.paymentMethods != null) {
        emit(state.copyWith(
          isLoading: false,
          paymentMethods: result,
          currentPage: 1,
          hasReachedMax: result.paymentMethods!.isEmpty,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to search payment methods',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    return super.close();
  }
}
