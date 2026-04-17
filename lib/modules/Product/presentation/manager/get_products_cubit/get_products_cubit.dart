import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/utils/network_connection.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repos/product_repo.dart';

part 'get_products_event.dart';
part 'get_products_state.dart';

class GetProductsCubit extends Bloc<GetProductsEvent, GetProductsState> {
  final ProductRepo _productRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetProductsCubit(this._productRepo) : super(const GetProductsState()) {
    on<GetAllProductsEvent>(_onGetAllProducts);
    on<RefreshProductsEvent>(_onRefreshProducts);
    on<SetProductPageEvent>(_onSetPage);
    on<SetProductSearchEvent>(_onSetSearch);
    on<SetProductClinicFilterEvent>(_onSetClinicFilter);
    on<SetProductSubCategoryFilterEvent>(_onSetSubCategoryFilter);
    on<SetProductActiveOnlyFilterEvent>(_onSetActiveOnlyFilter);
    on<ResetProductFilters>(_onResetFilters);
    on<UpdateLocalProductEvent>(_onUpdateLocalProduct);
    on<DeleteLocalProductEvent>(_onDeleteLocalProduct);
    on<AddLocalProductEvent>(_onAddLocalProduct);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllProductsEvent(page: 1));
    });
  }

  void onSearchChanged(String searchText) {
    add(SetProductSearchEvent(searchText));
    _searchSubject.add(searchText);
  }

  Future<void> _onGetAllProducts(
      GetAllProductsEvent event, Emitter<GetProductsState> emit) async {
    try {
      emit(state.copyWith(
        status: GetProductsStatus.loading,
        page: event.page ?? state.page,
        search: event.search ?? state.search,
        clinicFilter: event.clinicId ?? state.clinicFilter,
        subCategoryFilter: event.subCategoryId ?? state.subCategoryFilter,
        activeOnly: event.activeOnly ?? state.activeOnly,
      ));

      if (!await NetworkStatus().hasInternetConnection()) {
        emit(state.copyWith(status: GetProductsStatus.noConnection));
        return;
      }

      final products = await _productRepo.getAllProducts(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        subCategory: state.subCategoryFilter,
        activeOnly: state.activeOnly,
      );

      emit(state.copyWith(
        status: GetProductsStatus.success,
        products: products,
      ));
    } catch (e) {
      log(e.toString());
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetProductsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRefreshProducts(
      RefreshProductsEvent event, Emitter<GetProductsState> emit) {
    add(GetAllProductsEvent(page: 1));
  }

  void _onSetPage(SetProductPageEvent event, Emitter<GetProductsState> emit) {
    emit(state.copyWith(page: event.page));
    add(GetAllProductsEvent());
  }

  void _onSetSearch(
      SetProductSearchEvent event, Emitter<GetProductsState> emit) {
    emit(state.copyWith(search: event.search, page: 1));
  }

  void _onSetClinicFilter(
      SetProductClinicFilterEvent event, Emitter<GetProductsState> emit) {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllProductsEvent());
  }

  void _onSetSubCategoryFilter(
      SetProductSubCategoryFilterEvent event, Emitter<GetProductsState> emit) {
    emit(state.copyWith(subCategoryFilter: event.subCategoryId, page: 1));
    add(GetAllProductsEvent());
  }

  void _onSetActiveOnlyFilter(
      SetProductActiveOnlyFilterEvent event, Emitter<GetProductsState> emit) {
    emit(state.copyWith(activeOnly: event.activeOnly, page: 1));
    add(GetAllProductsEvent());
  }

  void _onResetFilters(
      ResetProductFilters event, Emitter<GetProductsState> emit) {
    emit(const GetProductsState());
    add(GetAllProductsEvent(page: 1));
  }

  void _onUpdateLocalProduct(
      UpdateLocalProductEvent event, Emitter<GetProductsState> emit) {
    if (state.products?.products != null) {
      final updatedProducts = state.products!.products.map((p) {
        return p.id == event.product.id ? event.product : p;
      }).toList();
      emit(state.copyWith(
        products: state.products!.copyWith(products: updatedProducts),
      ));
    }
  }

  void _onDeleteLocalProduct(
      DeleteLocalProductEvent event, Emitter<GetProductsState> emit) {
    if (state.products?.products != null) {
      final updatedProducts = state.products!.products
          .where((p) => p.id != event.productId)
          .toList();
      emit(state.copyWith(
        products: state.products!.copyWith(products: updatedProducts),
      ));
    }
  }

  void _onAddLocalProduct(
      AddLocalProductEvent event, Emitter<GetProductsState> emit) {
    if (state.products != null) {
      final updatedProducts = [event.product, ...?state.products?.products];
      emit(state.copyWith(
        products: state.products!.copyWith(products: updatedProducts),
      ));
    }
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
