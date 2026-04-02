import 'package:bloc/bloc.dart';
import '../../../data/model/patient_overview_model.dart';
import '../../../data/repos/examination_repo.dart';

part 'patient_overview_state.dart';

class PatientOverviewCubit extends Cubit<PatientOverviewState> {
  final ExaminationRepo examinationRepo;

  PatientOverviewCubit(this.examinationRepo)
      : super(PatientOverviewInitial());

  Future<void> getPatientOverview(String patientId) async {
    emit(PatientOverviewLoading());
    try {
      final result =
          await examinationRepo.getPatientOverview(patientId: patientId);
      emit(PatientOverviewSuccess(result));
    } catch (e) {
      emit(PatientOverviewError(e.toString()));
    }
  }
}
