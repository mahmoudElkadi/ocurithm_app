import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/medicine_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'get_medicines_state.dart';

class GetMedicinesCubit extends Cubit<GetMedicinesState> {
  final MedicineRepo medicineRepo;

  GetMedicinesCubit({required this.medicineRepo})
      : super(GetMedicinesInitial());

  static GetMedicinesCubit get(context) => BlocProvider.of(context);

  List<CommercialName> medicines = [];
  int page = 1;

  Future<void> getMedicines({String? search, bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      medicines = [];
      emit(GetMedicinesLoading());
    } else if (page == 1) {
      emit(GetMedicinesLoading());
    }

    try {
      final result =
          await medicineRepo.getAllMedicines(page: page, search: search);
      if (isRefresh || page == 1) {
        medicines = result.commercialNames;
      } else {
        medicines.addAll(result.commercialNames);
      }

      bool hasMore = result.totalPages != null && page < result.totalPages!;
      if (result.commercialNames.isNotEmpty) {
        page++;
      }

      emit(GetMedicinesLoaded(medicines: medicines, hasMore: hasMore));
    } catch (e) {
      emit(GetMedicinesError(error: e.toString()));
    }
  }
}
