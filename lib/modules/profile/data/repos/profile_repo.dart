import '../../../../core/api/api_model.dart';
import '../models/profile_models.dart';

abstract class ProfileRepo {
  Future<ApiResponse<ProfileModel>> getProfile();
  Future<ApiResponse<ProfileModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? image,
    bool removeImage = false,
  });
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
