part of 'get_branches_cubit.dart';

@immutable
abstract class GetBranchesEvent {}

class GetAllBranchesEvent extends GetBranchesEvent {
  final int? page;
  final String? search;
  final String? clinicId;

  GetAllBranchesEvent({this.page, this.search, this.clinicId});
}

class RefreshBranchesEvent extends GetBranchesEvent {}

class SetPageEvent extends GetBranchesEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetBranchesEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class SetClinicFilterEvent extends GetBranchesEvent {
  final String? clinicId;

  SetClinicFilterEvent(this.clinicId);
}

class RemoveBranchesEvent extends GetBranchesEvent {
  final int index;

  RemoveBranchesEvent(this.index);
}

class ResetBranchFilters extends GetBranchesEvent {}
