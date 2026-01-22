import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'get_patient_examinations_event.dart';
part 'get_patient_examinations_state.dart';

class GetPatientExaminationsCubit extends Cubit<GetPatientExaminationsState> {
  final PatientRepo patientRepo;

  GetPatientExaminationsCubit(this.patientRepo)
      : super(const GetPatientExaminationsState());

  Future<void> getExaminations(String patientId) async {
    emit(const GetPatientExaminationsState(
        status: GetPatientExaminationsStatus.loading));
    try {
      final result = await patientRepo.getPatientExaminations(id: patientId);
      if (result.success == true) {
        emit(GetPatientExaminationsState(
          status: GetPatientExaminationsStatus.success,
          examinations: result,
        ));
      }
    } catch (e) {
      emit(GetPatientExaminationsState(
        status: GetPatientExaminationsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
