part of 'save_reason_actions_cubit.dart';

/// Events for SaveReasonActionsCubit
abstract class SaveReasonActionsEvent {
  const SaveReasonActionsEvent();
}

class AddSaveReasonEvent extends SaveReasonActionsEvent {
  final SaveReason saveReason;

  const AddSaveReasonEvent(this.saveReason);
}

class UpdateSaveReasonEvent extends SaveReasonActionsEvent {
  final String saveReasonId;
  final SaveReason saveReason;

  const UpdateSaveReasonEvent({
    required this.saveReasonId,
    required this.saveReason,
  });
}

class DeleteSaveReasonEvent extends SaveReasonActionsEvent {
  final String saveReasonId;

  const DeleteSaveReasonEvent(this.saveReasonId);
}

class ResetSaveReasonActionsEvent extends SaveReasonActionsEvent {
  const ResetSaveReasonActionsEvent();
}
