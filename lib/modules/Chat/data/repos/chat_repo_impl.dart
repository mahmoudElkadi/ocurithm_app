import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_model.dart';
import '../../../../core/api/api_constants.dart';
import '../models/chat_models.dart';
import 'chat_repo.dart';

/// Implementation of ChatRepo using ApiHandler
class ChatRepoImpl implements ChatRepo {
  final ApiHandler _apiHandler = ApiHandler();

  // ─────────────────────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────────────────────

  @override
  Future<ApiResponse<List<ChatUserModel>>> getChattableUsers({
    String? search,
    String? userType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (userType != null && userType.isNotEmpty) {
        queryParams['userType'] = userType;
      }

      final response = await _apiHandler.get<List<ChatUserModel>>(
        ApiConstants.chatUsers,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final users = json['users'] as List<dynamic>? ?? [];
            return users
                .map((e) => ChatUserModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to fetch chattable users";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // THREADS
  // ─────────────────────────────────────────────────────────────

  @override
  Future<ApiResponse<List<ThreadModel>>> getThreads({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiHandler.get<List<ThreadModel>>(
        ApiConstants.chatThreads,
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final threads = json['threads'] as List<dynamic>? ?? [];
            return threads
                .map((e) => ThreadModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to fetch threads";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<ThreadModel>> createThread({
    required String participantId,
  }) async {
    try {
      final response = await _apiHandler.post<ThreadModel>(
        ApiConstants.chatThreads,
        data: {
          'participantId': participantId,
        },
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final thread = json['thread'] as Map<String, dynamic>?;
            if (thread != null) {
              return ThreadModel.fromJson(thread);
            }
          }
          throw "Invalid response format";
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to create thread";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<ThreadModel>> getThread({
    required String threadId,
  }) async {
    try {
      final response = await _apiHandler.get<ThreadModel>(
        ApiConstants.chatThread(threadId),
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final thread = json['thread'] as Map<String, dynamic>?;
            if (thread != null) {
              return ThreadModel.fromJson(thread);
            }
          }
          throw "Invalid response format";
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to fetch thread";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MESSAGES
  // ─────────────────────────────────────────────────────────────

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMessages({
    required String threadId,
    int limit = 30,
    String? before,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (before != null && before.isNotEmpty) {
        queryParams['before'] = before;
      }

      final response = await _apiHandler.get<Map<String, dynamic>>(
        ApiConstants.chatMessages(threadId),
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final messages = (json['messages'] as List<dynamic>? ?? [])
                .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
                .toList();
            return {
              'messages': messages,
              'hasMore': json['hasMore'] ?? false,
              'nextCursor': json['nextCursor'],
            };
          }
          return {
            'messages': <MessageModel>[],
            'hasMore': false,
            'nextCursor': null,
          };
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to fetch messages";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<MessageModel>> sendMessage({
    required String threadId,
    required String content,
  }) async {
    try {
      final response = await _apiHandler.post<MessageModel>(
        ApiConstants.chatMessages(threadId),
        data: {
          'content': content,
        },
        fromJson: (json) {
          if (json is Map<String, dynamic>) {
            final message = json['message'] as Map<String, dynamic>?;
            if (message != null) {
              return MessageModel.fromJson(message);
            }
          }
          throw "Invalid response format";
        },
      );

      if (!response.success) {
        throw response.message ?? "Failed to send message";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
