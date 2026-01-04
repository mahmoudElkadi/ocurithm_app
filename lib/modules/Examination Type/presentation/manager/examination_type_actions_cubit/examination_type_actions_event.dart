part of 'examination_type_actions_cubit.dart';

/// Events for ExaminationTypeActionsCubit
abstract class ExaminationTypeActionsEvent {
  const ExaminationTypeActionsEvent();
}

/// Event to add a new examination type
class AddExaminationTypeEvent extends ExaminationTypeActionsEvent {
  final ExaminationType examinationType;

  const AddExaminationTypeEvent(this.examinationType);
}

/// Event to update an existing examination type
class UpdateExaminationTypeEvent extends ExaminationTypeActionsEvent {
  final String examinationTypeId;
  final ExaminationType examinationType;

  const UpdateExaminationTypeEvent({
    required this.examinationTypeId,
    required this.examinationType,
  });
}

/// Event to delete an examination type
class DeleteExaminationTypeEvent extends ExaminationTypeActionsEvent {
  final String examinationTypeId;

  const DeleteExaminationTypeEvent(this.examinationTypeId);
}

/// Event to reset the actions state
class ResetExaminationTypeActionsEvent extends ExaminationTypeActionsEvent {
  const ResetExaminationTypeActionsEvent();
}
