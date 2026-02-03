part of 'get_examination_types_cubit.dart';

/// Events for GetExaminationTypesCubit
abstract class GetExaminationTypesEvent {
  const GetExaminationTypesEvent();
}

/// Event to get examination types with optional page
class GetAllExaminationTypesEvent extends GetExaminationTypesEvent {
  final int page;
  const GetAllExaminationTypesEvent({this.page = 1});
}

/// Event to set search query (doesn't trigger search immediately)
class SetSearchEvent extends GetExaminationTypesEvent {
  final String query;

  const SetSearchEvent(this.query);
}
