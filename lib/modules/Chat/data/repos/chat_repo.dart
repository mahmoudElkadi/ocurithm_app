import '../../../../core/api/api_model.dart';
import '../models/chat_models.dart';

/// Abstract repository for Chat module operations
abstract class ChatRepo {
  // ─────────────────────────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────────────────────────

  /// Get list of users available for chat
  Future<ApiResponse<List<ChatUserModel>>> getChattableUsers({
    String? search,
    String? userType,
  });

  // ─────────────────────────────────────────────────────────────
  // THREADS
  // ─────────────────────────────────────────────────────────────

  /// Get list of chat threads for current user
  Future<ApiResponse<List<ThreadModel>>> getThreads({
    int page = 1,
    int limit = 20,
    String? search,
  });

  /// Create or get existing thread with a user
  Future<ApiResponse<ThreadModel>> createThread({
    required String participantId,
  });

  /// Get thread details by ID
  Future<ApiResponse<ThreadModel>> getThread({
    required String threadId,
  });

  // ─────────────────────────────────────────────────────────────
  // MESSAGES
  // ─────────────────────────────────────────────────────────────

  /// Get paginated messages for a thread
  Future<ApiResponse<Map<String, dynamic>>> getMessages({
    required String threadId,
    int limit = 30,
    String? before, // Cursor for pagination
  });

  /// Send a message to a thread
  Future<ApiResponse<MessageModel>> sendMessage({
    required String threadId,
    required String content,
  });
}
