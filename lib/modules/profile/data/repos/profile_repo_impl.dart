import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_model.dart';
import '../models/profile_models.dart';
import 'profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  @override
  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _apiHandler.get<ProfileModel>(
        'profile/me',
        fromJson: (json) => ProfileModel.fromJson(json),
      );
      if (!response.success) {
        throw response.message ?? "Failed to fetch profile";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<ProfileModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? image,
    bool removeImage = false,
  }) async {
    try {
      final response = await _apiHandler.patch<ProfileModel>(
        'profile/me',
        data: {
          if (name != null && name.isNotEmpty) "name": name,
          if (email != null && email.isNotEmpty) "email": email,
          if (phone != null && phone.isNotEmpty) "phone": phone,
          if (removeImage) "image": null else if (image != null) "image": image,
        },
        fromJson: (json) => ProfileModel.fromJson(json),
      );
      if (!response.success) {
        throw response.message ?? "Failed to update profile";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiHandler.patch(
        'profile/password',
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
      if (!response.success) {
        throw response.message ?? "Failed to change password";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
