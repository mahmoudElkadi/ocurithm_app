import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';

part 'get_one_examination_event.dart';
part 'get_one_examination_state.dart';

class GetOneExaminationCubit extends Cubit<GetOneExaminationState> {
  final PatientRepo patientRepo;

  GetOneExaminationCubit(this.patientRepo)
      : super(const GetOneExaminationState());

  Future<void> getExamination(String id) async {
    emit(const GetOneExaminationState(status: GetOneExaminationStatus.loading));
    try {
      final result = await patientRepo.getOneExamination(id: id);
      if (result.error != null) {
        emit(GetOneExaminationState(
            status: GetOneExaminationStatus.error, errorMessage: result.error));
      } else {
        emit(GetOneExaminationState(
            status: GetOneExaminationStatus.success, examination: result));
      }
    } catch (e) {
      emit(GetOneExaminationState(
          status: GetOneExaminationStatus.error, errorMessage: e.toString()));
    }
  }
}
