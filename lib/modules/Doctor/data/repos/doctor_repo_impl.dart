import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/doctor_model.dart';
import 'doctor_repo.dart';

/// Repository implementation for Doctor operations
/// Uses ApiHandler for all API calls (following the new pattern)
class DoctorRepoImpl implements DoctorRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<Doctor> createDoctor({required Doctor doctor}) async {
    try {
      // Sanitize and validate data before sending
      Map<String, dynamic> data = {
        "name": doctor.name?.trim(),
        "phone": doctor.phone?.trim(),
        "password": doctor.password,
        "clinic": doctor.clinic?.id,
        if (doctor.birthDate != null) "birthDate": doctor.birthDate.toString(),
        if (doctor.qualifications != null && doctor.qualifications!.isNotEmpty)
          "qualifications": doctor.qualifications,
        if (doctor.image != null && doctor.image!.isNotEmpty)
          "image": doctor.image,
      };

      final response = await _apiHandler.post<Doctor>(
        ApiConstants.doctors,
        data: data,
        cancelKey: 'createDoctor',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to create doctor');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DoctorModel> getAllDoctors({
    int? page,
    String? search,
    String? branch,
    String? clinic,
    bool? isActive,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (page != null) 'limit': 10,
        if (search != null && search.isNotEmpty) "search": search,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (branch != null && branch.isNotEmpty) "branch": branch,
        if (isActive != null) "isActive": isActive,
      };

      final response = await _apiHandler.get<DoctorModel>(
        ApiConstants.doctors,
        queryParameters: query,
        cancelKey: 'getAllDoctors',
        fromJson: (json) => DoctorModel.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Doctor> getDoctor({required String id}) async {
    try {
      final response = await _apiHandler.get<Doctor>(
        '${ApiConstants.doctors}/$id',
        cancelKey: 'getDoctor',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to fetch doctor');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Doctor> updateDoctor(
      {required String id, required Doctor doctor}) async {
    try {
      Map<String, dynamic> data = {
        "name": doctor.name?.trim(),
        "phone": doctor.phone?.trim(),
        "clinic": doctor.clinic?.id,
        if (doctor.birthDate != null) "birthDate": doctor.birthDate.toString(),
        if (doctor.capability != null && doctor.capability!.isNotEmpty)
          "capabilities": doctor.capability,
        if (doctor.qualifications != null && doctor.qualifications!.isNotEmpty)
          "qualifications": doctor.qualifications,
        if (doctor.image != null && doctor.image!.isNotEmpty)
          "image": doctor.image,
      };

      final response = await _apiHandler.put<Doctor>(
        '${ApiConstants.doctors}/$id',
        data: data,
        cancelKey: 'updateDoctor',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to update doctor');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataModel> deleteDoctor({required String id}) async {
    try {
      final response = await _apiHandler.delete<DataModel>(
        '${ApiConstants.doctors}/$id',
        cancelKey: 'deleteDoctor',
        fromJson: (json) => DataModel.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to delete doctor');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BranchesModel> getAllBranches() async {
    try {
      final response = await _apiHandler.get<BranchesModel>(
        ApiConstants.branches,
        cancelKey: 'getAllBranches',
        fromJson: (json) => BranchesModel.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to fetch branches');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Doctor> addBranch({
    required String doctorId,
    required String branchId,
    required String availableFrom,
    required String availableTo,
    required List availableDays,
  }) async {
    try {
      Map<String, dynamic> data = {
        "doctorId": doctorId,
        "branchId": branchId,
        "availableFrom": availableFrom,
        "availableTo": availableTo,
        "availableDays": availableDays,
      };

      final response = await _apiHandler.post<Doctor>(
        '${ApiConstants.doctors}/addBranch',
        data: data,
        cancelKey: 'addBranch',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to add branch');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Doctor> editBranch({
    required String doctorId,
    required String branchId,
    required String availableFrom,
    required String availableTo,
    required List availableDays,
  }) async {
    try {
      Map<String, dynamic> data = {
        "doctorId": doctorId,
        "branchId": branchId,
        "availableFrom": availableFrom,
        "availableTo": availableTo,
        "availableDays": availableDays,
      };

      final response = await _apiHandler.put<Doctor>(
        '${ApiConstants.doctors}/editBranch',
        data: data,
        cancelKey: 'editBranch',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to edit branch');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Doctor> deleteBranch({
    required String doctorId,
    required String branchId,
  }) async {
    try {
      Map<String, dynamic> data = {
        "doctorId": doctorId,
        "branchId": branchId,
      };

      final response = await _apiHandler.delete<Doctor>(
        '${ApiConstants.doctors}/deleteBranch',
        data: data,
        cancelKey: 'deleteBranch',
        fromJson: (json) => Doctor.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to delete branch');
      }
    } catch (e) {
      rethrow;
    }
  }
}
