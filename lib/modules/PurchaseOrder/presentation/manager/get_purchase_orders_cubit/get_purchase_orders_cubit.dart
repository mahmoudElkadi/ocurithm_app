import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/utils/network_connection.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../data/repos/purchase_order_repo.dart';

part 'get_purchase_orders_event.dart';
part 'get_purchase_orders_state.dart';

class GetPurchaseOrdersCubit extends Bloc<GetPurchaseOrdersEvent, GetPurchaseOrdersState> {
  final PurchaseOrderRepo _purchaseOrderRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetPurchaseOrdersCubit(this._purchaseOrderRepo) : super(const GetPurchaseOrdersState()) {
    on<GetAllPurchaseOrdersEvent>(_onGetAllPurchaseOrders);
    on<RefreshPurchaseOrdersEvent>(_onRefreshPurchaseOrders);
    on<SetPOPageEvent>(_onSetPage);
    on<SetPOSearchEvent>(_onSetSearch);
    on<SetPOSupplierFilterEvent>(_onSetSupplierFilter);
    on<SetPOClinicFilterEvent>(_onSetClinicFilter);
    on<SetPODateRangeFilterEvent>(_onSetDateRangeFilter);
    on<ResetPOFilters>(_onResetFilters);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllPurchaseOrdersEvent(page: 1));
    });
  }

  void onSearchChanged(String searchText) {
    add(SetPOSearchEvent(searchText));
    _searchSubject.add(searchText);
  }

  Future<void> _onGetAllPurchaseOrders(
      GetAllPurchaseOrdersEvent event, Emitter<GetPurchaseOrdersState> emit) async {
    try {
      emit(state.copyWith(
        status: GetPurchaseOrdersStatus.loading,
        page: event.page ?? state.page,
        search: event.search ?? state.search,
        supplierFilter: event.supplierId ?? state.supplierFilter,
        clinicFilter: event.clinicId ?? state.clinicFilter,
        fromDate: event.fromDate ?? state.fromDate,
        toDate: event.toDate ?? state.toDate,
      ));

      if (!await NetworkStatus().hasInternetConnection()) {
        emit(state.copyWith(status: GetPurchaseOrdersStatus.noConnection));
        return;
      }

      final purchaseOrders = await _purchaseOrderRepo.getAllPurchaseOrders(
        page: state.page,
        search: state.search,
        supplierId: state.supplierFilter,
        clinicId: state.clinicFilter,
        fromDate: state.fromDate,
        toDate: state.toDate,
      );

      emit(state.copyWith(
        status: GetPurchaseOrdersStatus.success,
        purchaseOrders: purchaseOrders,
      ));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
        status: GetPurchaseOrdersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRefreshPurchaseOrders(
      RefreshPurchaseOrdersEvent event, Emitter<GetPurchaseOrdersState> emit) {
    add(GetAllPurchaseOrdersEvent(page: 1));
  }

  void _onSetPage(SetPOPageEvent event, Emitter<GetPurchaseOrdersState> emit) {
    emit(state.copyWith(page: event.page));
    add(GetAllPurchaseOrdersEvent());
  }

  void _onSetSearch(
      SetPOSearchEvent event, Emitter<GetPurchaseOrdersState> emit) {
    emit(state.copyWith(search: event.search, page: 1));
  }

  void _onSetSupplierFilter(
      SetPOSupplierFilterEvent event, Emitter<GetPurchaseOrdersState> emit) {
    emit(state.copyWith(supplierFilter: event.supplierId, page: 1));
    add(GetAllPurchaseOrdersEvent());
  }

  void _onSetClinicFilter(
      SetPOClinicFilterEvent event, Emitter<GetPurchaseOrdersState> emit) {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllPurchaseOrdersEvent());
  }

  void _onSetDateRangeFilter(
      SetPODateRangeFilterEvent event, Emitter<GetPurchaseOrdersState> emit) {
    emit(state.copyWith(
      fromDate: event.fromDate,
      toDate: event.toDate,
      page: 1,
    ));
    add(GetAllPurchaseOrdersEvent());
  }

  void _onResetFilters(
      ResetPOFilters event, Emitter<GetPurchaseOrdersState> emit) {
    emit(const GetPurchaseOrdersState());
    add(GetAllPurchaseOrdersEvent(page: 1));
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
