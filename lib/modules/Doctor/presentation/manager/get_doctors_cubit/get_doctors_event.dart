part of 'get_doctors_cubit.dart';

@immutable
abstract class GetDoctorsEvent {}

class GetAllDoctorsEvent extends GetDoctorsEvent {
  final int? page;
  final String? search;
  final String? clinicId;
  final String? branchId;

  GetAllDoctorsEvent({this.page, this.search, this.clinicId, this.branchId});
}

class RefreshDoctorsEvent extends GetDoctorsEvent {}

class SetPageEvent extends GetDoctorsEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetDoctorsEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class SetClinicFilterEvent extends GetDoctorsEvent {
  final String? clinicId;

  SetClinicFilterEvent(this.clinicId);
}

class SetBranchFilterEvent extends GetDoctorsEvent {
  final String? branchId;

  SetBranchFilterEvent(this.branchId);
}

class RemoveDoctorEvent extends GetDoctorsEvent {
  final int index;

  RemoveDoctorEvent(this.index);
}

class ResetDoctorFilters extends GetDoctorsEvent {}
