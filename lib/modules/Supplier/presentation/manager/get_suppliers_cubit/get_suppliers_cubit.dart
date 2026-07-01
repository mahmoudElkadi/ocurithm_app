import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/utils/network_connection.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/repos/supplier_repo.dart';

part 'get_suppliers_event.dart';
part 'get_suppliers_state.dart';

class GetSuppliersCubit extends Bloc<GetSuppliersEvent, GetSuppliersState> {
  final SupplierRepo _supplierRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetSuppliersCubit(this._supplierRepo) : super(const GetSuppliersState()) {
    on<GetAllSuppliersEvent>(_onGetAllSuppliers);
    on<RefreshSuppliersEvent>(_onRefreshSuppliers);
    on<SetSupplierPageEvent>(_onSetPage);
    on<SetSupplierSearchEvent>(_onSetSearch);
    on<SetSupplierClinicFilterEvent>(_onSetClinicFilter);
    on<SetSupplierActiveOnlyFilterEvent>(_onSetActiveOnlyFilter);
    on<ResetSupplierFilters>(_onResetFilters);
    on<AddLocalSupplierEvent>(_onAddLocalSupplier);
    on<UpdateLocalSupplierEvent>(_onUpdateLocalSupplier);
    on<DeleteLocalSupplierEvent>(_onDeleteLocalSupplier);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllSuppliersEvent(page: 1));
    });
  }

  void onSearchChanged(String searchText) {
    add(SetSupplierSearchEvent(searchText));
    _searchSubject.add(searchText);
  }

  Future<void> _onGetAllSuppliers(
      GetAllSuppliersEvent event, Emitter<GetSuppliersState> emit) async {
    try {
      emit(state.copyWith(
        status: GetSuppliersStatus.loading,
        page: event.page ?? state.page,
        search: event.search ?? state.search,
        clinicFilter: event.clinicId ?? state.clinicFilter,
        activeOnly: event.activeOnly ?? state.activeOnly,
      ));

      if (!await NetworkStatus().hasInternetConnection()) {
        emit(state.copyWith(status: GetSuppliersStatus.noConnection));
        return;
      }

      final suppliers = await _supplierRepo.getAllSuppliers(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        activeOnly: state.activeOnly,
      );

      emit(state.copyWith(
        status: GetSuppliersStatus.success,
        suppliers: suppliers,
      ));
    } catch (e) {
      log(e.toString());
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetSuppliersStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetSuppliersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRefreshSuppliers(
      RefreshSuppliersEvent event, Emitter<GetSuppliersState> emit) {
    add(GetAllSuppliersEvent(page: 1));
  }

  void _onSetPage(SetSupplierPageEvent event, Emitter<GetSuppliersState> emit) {
    emit(state.copyWith(page: event.page));
    add(GetAllSuppliersEvent());
  }

  void _onSetSearch(
      SetSupplierSearchEvent event, Emitter<GetSuppliersState> emit) {
    emit(state.copyWith(search: event.search, page: 1));
  }

  void _onSetClinicFilter(
      SetSupplierClinicFilterEvent event, Emitter<GetSuppliersState> emit) {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllSuppliersEvent());
  }

  void _onSetActiveOnlyFilter(
      SetSupplierActiveOnlyFilterEvent event, Emitter<GetSuppliersState> emit) {
    emit(state.copyWith(activeOnly: event.activeOnly, page: 1));
    add(GetAllSuppliersEvent());
  }

  void _onResetFilters(
      ResetSupplierFilters event, Emitter<GetSuppliersState> emit) {
    emit(const GetSuppliersState());
    add(GetAllSuppliersEvent(page: 1));
  }

  void _onAddLocalSupplier(
      AddLocalSupplierEvent event, Emitter<GetSuppliersState> emit) {
    final currentSuppliers = state.suppliers?.suppliers ?? [];
    final updatedList = [event.supplier, ...currentSuppliers];
    final currentTotal = state.suppliers?.total ?? 0;
    emit(state.copyWith(
      suppliers: (state.suppliers ?? SupplierModel(suppliers: []))
          .copyWith(suppliers: updatedList, total: currentTotal + 1),
    ));
  }

  void _onUpdateLocalSupplier(
      UpdateLocalSupplierEvent event, Emitter<GetSuppliersState> emit) {
    if (state.suppliers?.suppliers != null) {
      final updatedSuppliers = state.suppliers!.suppliers.map((s) {
        return s.id == event.supplier.id ? event.supplier : s;
      }).toList();
      emit(state.copyWith(
        suppliers: state.suppliers!.copyWith(suppliers: updatedSuppliers),
      ));
    }
  }

  void _onDeleteLocalSupplier(
      DeleteLocalSupplierEvent event, Emitter<GetSuppliersState> emit) {
    if (state.suppliers?.suppliers != null) {
      final updatedSuppliers = state.suppliers!.suppliers
          .where((s) => s.id != event.supplierId)
          .toList();
      emit(state.copyWith(
        suppliers: state.suppliers!.copyWith(suppliers: updatedSuppliers),
      ));
    }
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
