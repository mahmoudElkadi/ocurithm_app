import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<SetClinicFilterEvent>(_onSetClinicFilter);

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
    emit(state.copyWith(
      state: GetPaymentMethodsStatus.loading,
      errorMessage: null,
    ));

    try {
      // Fetch payment methods
      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: event.noPagination ? null : 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        clinic: state.clinicFilter,
      );

      emit(state.copyWith(
        state: GetPaymentMethodsStatus.success,
        paymentMethods: result,
        currentPage: 1,
        hasReachedMax: result.paymentMethods?.isEmpty ?? true,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetPaymentMethodsStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          state: GetPaymentMethodsStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Load more payment methods (next page)
  Future<void> _onLoadMorePaymentMethods(
    LoadMorePaymentMethodsEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(state: GetPaymentMethodsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: nextPage,
        search: state.searchQuery,
        clinic: state.clinicFilter,
      );

      // Merge new payment methods with existing ones
      final updatedPaymentMethodsList =
          List<PaymentMethod>.from(state.paymentMethods?.paymentMethods ?? []);
      updatedPaymentMethodsList.addAll(result.paymentMethods ?? []);

      emit(state.copyWith(
        state: GetPaymentMethodsStatus.success,
        paymentMethods: state.paymentMethods?.copyWith(
          paymentMethods: updatedPaymentMethodsList,
        ),
        currentPage: nextPage,
        hasReachedMax: result.paymentMethods?.isEmpty ?? true,
      ));
    } catch (e) {
      emit(state.copyWith(
        state: GetPaymentMethodsStatus.error,
        errorMessage: e.toString(),
      ));
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
    emit(state.copyWith(
      state: GetPaymentMethodsStatus.loading,
      errorMessage: null,
    ));

    try {
      final result = await paymentMethodRepo.getAllPaymentMethods(
        page: 1,
        search: event.query,
        clinic: state.clinicFilter,
      );

      emit(state.copyWith(
        state: GetPaymentMethodsStatus.success,
        paymentMethods: result,
        currentPage: 1,
        hasReachedMax: result.paymentMethods?.isEmpty ?? true,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetPaymentMethodsStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          state: GetPaymentMethodsStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Set clinic filter
  void _onSetClinicFilter(
    SetClinicFilterEvent event,
    Emitter<GetPaymentMethodsState> emit,
  ) {
    emit(state.copyWith(clinicFilter: event.clinicId, currentPage: 1));
    add(const GetAllPaymentMethodsEvent(noPagination: true));
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    return super.close();
  }
}
