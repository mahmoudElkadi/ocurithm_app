part of 'get_chat_users_bloc.dart';

enum GetChatUsersStatus { initial, loading, success, error, noConnection }

extension GetChatUsersStatusX on GetChatUsersState {
  bool get isInitial => status == GetChatUsersStatus.initial;
  bool get isLoading => status == GetChatUsersStatus.loading;
  bool get isSuccess => status == GetChatUsersStatus.success;
  bool get isError => status == GetChatUsersStatus.error;
  bool get noConnection => status == GetChatUsersStatus.noConnection;
}

@immutable
class GetChatUsersState {
  final GetChatUsersStatus status;
  final List<ChatUserModel> users;
  final String? errorMessage;
  final String? searchQuery;
  final String? filterType;

  const GetChatUsersState({
    this.status = GetChatUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
    this.searchQuery,
    this.filterType,
  });

  GetChatUsersState copyWith({
    GetChatUsersStatus? status,
    List<ChatUserModel>? users,
    String? errorMessage,
    String? searchQuery,
    String? filterType,
  }) {
    return GetChatUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
    );
  }
}
