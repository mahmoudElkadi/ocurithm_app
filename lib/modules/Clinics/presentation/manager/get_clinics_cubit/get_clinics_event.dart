part of 'get_clinics_cubit.dart';

@immutable
abstract class GetClinicsEvent {}

class GetAllClinicsEvent extends GetClinicsEvent {
  final int? page;
  final String? search;

  GetAllClinicsEvent({this.page, this.search});
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

class ResetFiltersEvent extends GetClinicsEvent {}
