part of 'get_chat_users_bloc.dart';

@immutable
abstract class GetChatUsersEvent {}

/// Event to fetch chattable users
class FetchChatUsersEvent extends GetChatUsersEvent {}

/// Event to search users by name
class SearchChatUsersEvent extends GetChatUsersEvent {
  final String query;
  SearchChatUsersEvent(this.query);
}

/// Event to filter users by type
class FilterChatUsersByTypeEvent extends GetChatUsersEvent {
  final String? userType;
  FilterChatUsersByTypeEvent(this.userType);
}

/// Event to reset state
class ResetChatUsersEvent extends GetChatUsersEvent {}
