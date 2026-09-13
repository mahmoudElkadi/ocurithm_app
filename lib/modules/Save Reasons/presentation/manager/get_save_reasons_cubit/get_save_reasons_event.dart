part of 'get_save_reasons_cubit.dart';

/// Events for GetSaveReasonsCubit
abstract class GetSaveReasonsEvent {
  const GetSaveReasonsEvent();
}

/// Event to get all save reasons (first page)
class GetAllSaveReasonsEvent extends GetSaveReasonsEvent {
  final bool noPagination;
  const GetAllSaveReasonsEvent({this.noPagination = false});
}

/// Event to load more save reasons (next page)
class LoadMoreSaveReasonsEvent extends GetSaveReasonsEvent {
  const LoadMoreSaveReasonsEvent();
}

/// Event to set search query (doesn't trigger search immediately)
class SetSaveReasonSearchEvent extends GetSaveReasonsEvent {
  final String query;

  const SetSaveReasonSearchEvent(this.query);
}

/// Event to search save reasons (triggered after debounce)
class SearchSaveReasonsEvent extends GetSaveReasonsEvent {
  final String query;

  const SearchSaveReasonsEvent(this.query);
}
