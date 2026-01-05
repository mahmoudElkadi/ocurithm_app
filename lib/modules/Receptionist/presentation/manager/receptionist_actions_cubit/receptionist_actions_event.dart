part of 'receptionist_actions_cubit.dart';

@immutable
abstract class ReceptionistActionsEvent {}

class AddReceptionistEvent extends ReceptionistActionsEvent {
  final Receptionist receptionist;

  AddReceptionistEvent(this.receptionist);
}

class UpdateReceptionistEvent extends ReceptionistActionsEvent {
  final String receptionistId;
  final Receptionist receptionist;

  UpdateReceptionistEvent(
      {required this.receptionistId, required this.receptionist});
}

class DeleteReceptionistEvent extends ReceptionistActionsEvent {
  final String receptionistId;

  DeleteReceptionistEvent(this.receptionistId);
}

class ResetReceptionistActionsEvent extends ReceptionistActionsEvent {}
