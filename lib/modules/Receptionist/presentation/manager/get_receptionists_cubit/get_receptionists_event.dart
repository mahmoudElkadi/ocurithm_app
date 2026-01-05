part of 'get_receptionists_cubit.dart';

@immutable
abstract class GetReceptionistsEvent {}

class GetAllReceptionistsEvent extends GetReceptionistsEvent {
  final int? page;
  final String? search;
  final String? clinicId;
  final String? branchId;

  GetAllReceptionistsEvent(
      {this.page, this.search, this.clinicId, this.branchId});
}

class RefreshReceptionistsEvent extends GetReceptionistsEvent {}

class SetPageEvent extends GetReceptionistsEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetReceptionistsEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class SetClinicFilterEvent extends GetReceptionistsEvent {
  final String? clinicId;

  SetClinicFilterEvent(this.clinicId);
}

class SetBranchFilterEvent extends GetReceptionistsEvent {
  final String? branchId;

  SetBranchFilterEvent(this.branchId);
}

class RemoveReceptionistEvent extends GetReceptionistsEvent {
  final int index;

  RemoveReceptionistEvent(this.index);
}

class ResetReceptionistFilters extends GetReceptionistsEvent {}
