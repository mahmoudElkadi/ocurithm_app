part of 'examination_actions_cubit.dart';

@immutable
abstract class ExaminationActionsEvent {}

class CreateExaminationEvent extends ExaminationActionsEvent {
  final Map<String, dynamic> data;
  CreateExaminationEvent(this.data);
}

class UpdateExaminationEvent extends ExaminationActionsEvent {
  final String id;
  final Map<String, dynamic> data;
  UpdateExaminationEvent({required this.id, required this.data});
}

// Add other events if needed (delete, etc)
