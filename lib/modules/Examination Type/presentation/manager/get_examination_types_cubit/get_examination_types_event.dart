part of 'get_examination_types_cubit.dart';

/// Events for GetExaminationTypesCubit
abstract class GetExaminationTypesEvent {
  const GetExaminationTypesEvent();
}

/// Event to get examination types with optional page
class GetAllExaminationTypesEvent extends GetExaminationTypesEvent {
  final int? page;
  final bool noPagination;
  const GetAllExaminationTypesEvent({this.page, this.noPagination = false});
}

/// Event to set search query (doesn't trigger search immediately)
class SetSearchEvent extends GetExaminationTypesEvent {
  final String query;

  const SetSearchEvent(this.query);
}

class SetClinicFilterEvent extends GetExaminationTypesEvent {
  final String? clinicId;

  const SetClinicFilterEvent(this.clinicId);
}
