part of 'get_single_receptionist_cubit.dart';

@immutable
abstract class GetSingleReceptionistEvent {}

class GetReceptionistByIdEvent extends GetSingleReceptionistEvent {
  final String receptionistId;

  GetReceptionistByIdEvent(this.receptionistId);
}

class ResetSingleReceptionistEvent extends GetSingleReceptionistEvent {}
