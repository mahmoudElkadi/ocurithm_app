import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/utils/network_connection.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repos/order_repo.dart';

part 'get_orders_event.dart';
part 'get_orders_state.dart';

class GetOrdersBloc extends Bloc<GetOrdersEvent, GetOrdersState> {
  final OrderRepo _orderRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetOrdersBloc(this._orderRepo) : super(const GetOrdersState()) {
    on<GetAllOrdersEvent>(_onGetAllOrders);
    on<ResetOrderFilters>(_onResetFilters);
    on<SetOrderSearchEvent>(_onSetSearch);
    on<SetOrderPageEvent>(_onSetPage);
    on<SetOrderStatusFilterEvent>(_onSetStatusFilter);
    on<SetOrderBranchFilterEvent>(_onSetBranchFilter);
    on<SetOrderDoctorFilterEvent>(_onSetDoctorFilter);
    on<SetOrderDateRangeFilterEvent>(_onSetDateRangeFilter);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllOrdersEvent(page: 1));
    });
  }

  void onSearchChanged(String searchText) {
    add(SetOrderSearchEvent(searchText));
    _searchSubject.add(searchText);
  }

  Future<void> _onGetAllOrders(
      GetAllOrdersEvent event, Emitter<GetOrdersState> emit) async {
    try {
      emit(state.copyWith(
        status: GetOrdersStatus.loading,
        page: event.page ?? state.page,
        search: event.search ?? state.search,
        statusFilter: event.status ?? state.statusFilter,
        branchFilter: event.branch ?? state.branchFilter,
        doctorFilter: event.doctor ?? state.doctorFilter,
        startDate: event.startDate ?? state.startDate,
        endDate: event.endDate ?? state.endDate,
      ));

      if (!await NetworkStatus().hasInternetConnection()) {
        emit(state.copyWith(status: GetOrdersStatus.noConnection));
        return;
      }

      final orders = await _orderRepo.getAllOrders(
        page: state.page,
        search: state.search,
        status: state.statusFilter,
        branch: state.branchFilter,
        doctor: state.doctorFilter,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      emit(state.copyWith(
        status: GetOrdersStatus.success,
        orders: orders,
      ));
    } catch (e) {
      log(e.toString());
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetOrdersStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        status: GetOrdersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetFilters(
      ResetOrderFilters event, Emitter<GetOrdersState> emit) {
    emit(const GetOrdersState());
    add(GetAllOrdersEvent(page: 1));
  }

  void _onSetSearch(
      SetOrderSearchEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(search: event.search, page: 1));
  }

  void _onSetPage(SetOrderPageEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(page: event.page));
    add(GetAllOrdersEvent());
  }

  void _onSetStatusFilter(
      SetOrderStatusFilterEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(statusFilter: event.status, page: 1));
    add(GetAllOrdersEvent());
  }

  void _onSetBranchFilter(
      SetOrderBranchFilterEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(branchFilter: event.branch, page: 1));
    add(GetAllOrdersEvent());
  }

  void _onSetDoctorFilter(
      SetOrderDoctorFilterEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(doctorFilter: event.doctor, page: 1));
    add(GetAllOrdersEvent());
  }

  void _onSetDateRangeFilter(
      SetOrderDateRangeFilterEvent event, Emitter<GetOrdersState> emit) {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      page: 1,
    ));
    add(GetAllOrdersEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
