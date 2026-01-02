part of 'get_single_branch_cubit.dart';

@immutable
abstract class GetSingleBranchEvent {}

class GetBranchByIdEvent extends GetSingleBranchEvent {
  final String branchId;

  GetBranchByIdEvent(this.branchId);
}

class ResetSingleBranchEvent extends GetSingleBranchEvent {}
