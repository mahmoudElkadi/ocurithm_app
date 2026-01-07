part of 'get_patients_cubit.dart';

@immutable
abstract class GetPatientsEvent {}

class GetAllPatientsEvent extends GetPatientsEvent {
  final int? page;
  final String? search;
  final String? clinicId; // Kept for consistency, might be unused
  final String? branchId;

  GetAllPatientsEvent({this.page, this.search, this.clinicId, this.branchId});
}

class RefreshPatientsEvent extends GetPatientsEvent {}

class SetPageEvent extends GetPatientsEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetPatientsEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class SetClinicFilterEvent extends GetPatientsEvent {
  final String? clinicId;

  SetClinicFilterEvent(this.clinicId);
}

class SetBranchFilterEvent extends GetPatientsEvent {
  final String? branchId;

  SetBranchFilterEvent(this.branchId);
}

class RemovePatientEvent extends GetPatientsEvent {
  final int index;

  RemovePatientEvent(this.index);
}

class ResetPatientFilters extends GetPatientsEvent {}
