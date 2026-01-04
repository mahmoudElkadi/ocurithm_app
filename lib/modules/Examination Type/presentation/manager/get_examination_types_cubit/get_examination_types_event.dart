part of 'get_examination_types_cubit.dart';

/// Events for GetExaminationTypesCubit
abstract class GetExaminationTypesEvent {
  const GetExaminationTypesEvent();
}

/// Event to get all examination types (first page)
class GetAllExaminationTypesEvent extends GetExaminationTypesEvent {
  const GetAllExaminationTypesEvent();
}

/// Event to load more examination types (next page)
class LoadMoreExaminationTypesEvent extends GetExaminationTypesEvent {
  const LoadMoreExaminationTypesEvent();
}

/// Event to set search query (doesn't trigger search immediately)
class SetSearchEvent extends GetExaminationTypesEvent {
  final String query;

  const SetSearchEvent(this.query);
}

/// Event to search examination types (triggered after debounce)
class SearchExaminationTypesEvent extends GetExaminationTypesEvent {
  final String query;

  const SearchExaminationTypesEvent(this.query);
}
