import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';
import 'package:ocurithm/modules/SubCategory/data/repos/sub_category_repo.dart';

part 'get_sub_categories_state.dart';
part 'get_sub_categories_event.dart';

class GetSubCategoriesCubit extends Bloc<GetSubCategoriesEvent, GetSubCategoriesState> {
  final SubCategoryRepo subCategoryRepo;
  final _searchSubject = PublishSubject<String>();

  GetSubCategoriesCubit(this.subCategoryRepo) : super(GetSubCategoriesState()) {
    on<GetAllSubCategoriesEvent>(_onGetAllSubCategories);
    on<SetSubCategorySearchEvent>(_onSetSearch);
    on<SetSubCategoryClinicFilterEvent>(_onSetClinicFilter);
    on<SetSubCategoryCategoryFilterEvent>(_onSetCategoryFilter);
    on<ResetSubCategoryFilters>(_onResetFilters);
    on<SetSubCategoryPaginationEvent>(_onSetPagination);

    _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen((search) {
      add(SetSubCategorySearchEvent(search));
    });
  }

  void onSearchChanged(String search) => _searchSubject.add(search);

  Future<void> _onGetAllSubCategories(
      GetAllSubCategoriesEvent event, Emitter<GetSubCategoriesState> emit) async {
    emit(state.copyWith(status: GetSubCategoriesStatus.loading));
    try {
      final result = await subCategoryRepo.getAllSubCategories(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        category: state.categoryFilter,
        pagination: state.pagination,
      );
      emit(state.copyWith(
        status: GetSubCategoriesStatus.success,
        subCategories: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(status: GetSubCategoriesStatus.noConnection));
      } else {
        emit(state.copyWith(status: GetSubCategoriesStatus.error, errorMessage: e.toString()));
      }
    }
  }

  void _onSetSearch(SetSubCategorySearchEvent event, Emitter<GetSubCategoriesState> emit) {
    emit(state.copyWith(search: event.search, page: 1));
    add(GetAllSubCategoriesEvent());
  }

  void _onSetClinicFilter(SetSubCategoryClinicFilterEvent event, Emitter<GetSubCategoriesState> emit) {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllSubCategoriesEvent());
  }

  void _onSetCategoryFilter(SetSubCategoryCategoryFilterEvent event, Emitter<GetSubCategoriesState> emit) {
    emit(state.copyWith(categoryFilter: event.categoryId, page: 1));
    add(GetAllSubCategoriesEvent());
  }

  void _onSetPagination(SetSubCategoryPaginationEvent event, Emitter<GetSubCategoriesState> emit) {
    emit(state.copyWith(pagination: event.pagination));
  }

  void _onResetFilters(ResetSubCategoryFilters event, Emitter<GetSubCategoriesState> emit) {
    emit(state.copyWith(
      page: 1,
      search: '',
      clinicFilter: null,
      categoryFilter: null,
      pagination: "false",
    ));
    add(GetAllSubCategoriesEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
