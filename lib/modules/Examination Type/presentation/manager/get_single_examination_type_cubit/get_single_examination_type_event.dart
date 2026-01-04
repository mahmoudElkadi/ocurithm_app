part of 'get_single_examination_type_cubit.dart';

/// Events for GetSingleExaminationTypeCubit
abstract class GetSingleExaminationTypeEvent {
  const GetSingleExaminationTypeEvent();
}

/// Event to get a single examination type by ID
class GetExaminationTypeByIdEvent extends GetSingleExaminationTypeEvent {
  final String examinationTypeId;

  const GetExaminationTypeByIdEvent(this.examinationTypeId);
}

/// Event to reset the single examination type state
class ResetSingleExaminationTypeEvent extends GetSingleExaminationTypeEvent {
  const ResetSingleExaminationTypeEvent();
}
