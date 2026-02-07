import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_models.dart';
import '../../../data/repos/chat_repo.dart';

part 'get_chat_users_state.dart';
part 'get_chat_users_event.dart';

class GetChatUsersBloc extends Bloc<GetChatUsersEvent, GetChatUsersState> {
  final ChatRepo chatRepo;

  GetChatUsersBloc(this.chatRepo) : super(const GetChatUsersState()) {
    on<FetchChatUsersEvent>(_onFetchChatUsers);
    on<SearchChatUsersEvent>(_onSearchChatUsers);
    on<FilterChatUsersByTypeEvent>(_onFilterByType);
    on<ResetChatUsersEvent>(_onReset);
  }

  static GetChatUsersBloc get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onFetchChatUsers(
    FetchChatUsersEvent event,
    Emitter<GetChatUsersState> emit,
  ) async {
    try {
      emit(state.copyWith(status: GetChatUsersStatus.loading));

      final result = await chatRepo.getChattableUsers(
        search: state.searchQuery,
        userType: state.filterType,
      );

      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: GetChatUsersStatus.success,
          users: result.data,
        ));
      } else {
        emit(state.copyWith(
          status: GetChatUsersStatus.error,
          errorMessage: result.message ?? 'Failed to fetch users',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        // Silently fail on no connection to avoid UI disruption
        emit(state.copyWith(status: GetChatUsersStatus.error)); 
        return;
      }
      emit(state.copyWith(
        status: GetChatUsersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchChatUsers(
    SearchChatUsersEvent event,
    Emitter<GetChatUsersState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(FetchChatUsersEvent());
  }

  Future<void> _onFilterByType(
    FilterChatUsersByTypeEvent event,
    Emitter<GetChatUsersState> emit,
  ) async {
    emit(state.copyWith(filterType: event.userType));
    add(FetchChatUsersEvent());
  }

  Future<void> _onReset(
    ResetChatUsersEvent event,
    Emitter<GetChatUsersState> emit,
  ) async {
    emit(const GetChatUsersState());
  }
}
