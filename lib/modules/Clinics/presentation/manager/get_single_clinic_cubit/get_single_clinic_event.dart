part of 'get_single_clinic_cubit.dart';

@immutable
abstract class GetSingleClinicEvent {}

class GetClinicByIdEvent extends GetSingleClinicEvent {
  final String clinicId;

  GetClinicByIdEvent(this.clinicId);
}

class ResetSingleClinicEvent extends GetSingleClinicEvent {}
