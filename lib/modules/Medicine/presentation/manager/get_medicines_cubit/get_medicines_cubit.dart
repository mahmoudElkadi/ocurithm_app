import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/medicine_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'get_medicines_state.dart';
part 'get_medicines_event.dart';

class GetMedicinesCubit extends Bloc<GetMedicinesEvent, GetMedicinesState> {
  final MedicineRepo medicineRepo;

  GetMedicinesCubit({required this.medicineRepo})
      : super(const GetMedicinesState()) {
    on<FetchMedicinesEvent>(_onFetchMedicines);
    on<SetSearchEvent>(_onSetSearch);
    on<SetPageEvent>(_onSetPage);
    on<ResetFiltersEvent>(_onResetFilters);
  }

  static GetMedicinesCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> _onFetchMedicines(
      FetchMedicinesEvent event, Emitter<GetMedicinesState> emit) async {
    try {
      if (event.isRefresh) {
        emit(state.copyWith(
            status: GetMedicinesStatus.loading, page: 1, medicines: []));
      } else if (state.page == 1) {
        emit(state.copyWith(status: GetMedicinesStatus.loading));
      }

      final result = await medicineRepo.getAllMedicines(
        page: state.page,
        search: state.search,
      );

      List<CommercialName> updatedMedicines;
      if (event.isRefresh || state.page == 1) {
        updatedMedicines = result.commercialNames;
      } else {
        updatedMedicines = List.from(state.medicines)
          ..addAll(result.commercialNames);
      }

      int totalPages = result.totalPages?.toInt() ?? state.totalPages;
      bool hasMore =
          result.totalPages != null && state.page < result.totalPages!;

      emit(state.copyWith(
        status: GetMedicinesStatus.success,
        medicines: updatedMedicines,
        hasMore: hasMore,
        totalPages: totalPages,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetMedicinesStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetMedicinesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetMedicinesState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
    add(FetchMedicinesEvent(isRefresh: true));
  }

  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetMedicinesState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  Future<void> _onResetFilters(
      ResetFiltersEvent event, Emitter<GetMedicinesState> emit) async {
    emit(state.copyWith(page: 1, search: ''));
    add(FetchMedicinesEvent(isRefresh: true));
  }

  // Helper method to maintain existing UI logic
  void getMedicines({String? search, bool isRefresh = false, int? page}) {
    if (isRefresh) {
      add(FetchMedicinesEvent(isRefresh: true));
    } else if (page != null) {
      add(SetPageEvent(page));
      add(FetchMedicinesEvent());
    } else if (search != null) {
      add(SetSearchEvent(search));
    } else {
      add(FetchMedicinesEvent());
    }
  }
}
