import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repos/category_repo.dart';

part 'get_categories_state.dart';
part 'get_categories_event.dart';

class GetCategoriesCubit extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  final CategoryRepo categoryRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetCategoriesCubit(this.categoryRepo) : super(const GetCategoriesState()) {
    on<GetAllCategoriesEvent>(_onGetAllCategories);
    on<SetPageEvent>(_onSetPage);
    on<ResetCategoryFilters>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<SetClinicFilterEvent>(_onSetClinicFilter);
    on<SetPaginationEvent>(_onSetPagination);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllCategoriesEvent());
    });
  }

  static GetCategoriesCubit get(BuildContext context) =>
      BlocProvider.of(context);

  void onSearchChanged(String searchText) {
    add(SetSearchEvent(searchText));
    _searchSubject.add(searchText);
  }

  Future<void> _onGetAllCategories(
      GetAllCategoriesEvent event, Emitter<GetCategoriesState> emit) async {
    try {
      emit(state.copyWith(status: GetCategoriesStatus.loading));
      final categories = await categoryRepo.getAllCategories(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        pagination: state.pagination,
        limit: 10,
      );

      emit(state.copyWith(
        status: GetCategoriesStatus.success,
        categories: categories,
      ));
    } catch (e) {
      log(e.toString());
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetCategoriesStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetCategoriesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetCategoriesState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetCategoriesState> emit) async {
    emit(state.copyWith(page: event.page));
    add(GetAllCategoriesEvent());
  }

  Future<void> _onSetClinicFilter(
      SetClinicFilterEvent event, Emitter<GetCategoriesState> emit) async {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllCategoriesEvent());
  }

  Future<void> _onSetPagination(
      SetPaginationEvent event, Emitter<GetCategoriesState> emit) async {
    emit(state.copyWith(pagination: event.pagination, page: 1));
    add(GetAllCategoriesEvent());
  }

  Future<void> _onResetFilters(
      ResetCategoryFilters event, Emitter<GetCategoriesState> emit) async {
    emit(state.copyWith(
      page: 1,
      search: '',
      clinicFilter: null,
      pagination: "false",
    ));
    add(GetAllCategoriesEvent());
  }


  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
