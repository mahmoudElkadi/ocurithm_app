part of 'get_single_patient_cubit.dart';

@immutable
abstract class GetSinglePatientEvent {}

class GetPatientByIdEvent extends GetSinglePatientEvent {
  final String id;

  GetPatientByIdEvent(this.id);
}
