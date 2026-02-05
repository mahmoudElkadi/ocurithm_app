part of 'get_clinics_cubit.dart';

@immutable
abstract class GetClinicsEvent {}

class GetAllClinicsEvent extends GetClinicsEvent {
  final int? page;
  final String? search;
  final bool noPagination;

  GetAllClinicsEvent({this.page, this.search, this.noPagination = false});
}

class RefreshClinicsEvent extends GetClinicsEvent {}

class SetPageEvent extends GetClinicsEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetClinicsEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class RemoveClinicsEvent extends GetClinicsEvent {
  final int index;

  RemoveClinicsEvent(this.index);
}

class AddClinicToListEvent extends GetClinicsEvent {
  final Clinic clinic;

  AddClinicToListEvent(this.clinic);
}

class UpdateClinicInListEvent extends GetClinicsEvent {
  final Clinic clinic;

  UpdateClinicInListEvent(this.clinic);
}

class ResetFiltersEvent extends GetClinicsEvent {}
