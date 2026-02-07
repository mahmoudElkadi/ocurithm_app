import 'package:bloc/bloc.dart';
import '../../../data/repos/examination_repo.dart';
import '../../../data/model/saved_Exam.dart';

part 'get_single_examination_state.dart';

class GetSingleExaminationCubit extends Cubit<GetSingleExaminationState> {
  final ExaminationRepo examinationRepo;

  GetSingleExaminationCubit(this.examinationRepo)
      : super(GetSingleExaminationInitial());

  Future<void> getExamination(String id) async {
    emit(GetSingleExaminationLoading());
    try {
      final result = await examinationRepo.getOneExamination(appointmentId: id);
      if (result.success == true) {
        emit(GetSingleExaminationSuccess(result));
      } else {
        emit(GetSingleExaminationError('Failed to fetch examination'));
      }
    } catch (e) {
      emit(GetSingleExaminationError(e.toString()));
    }
  }
}
