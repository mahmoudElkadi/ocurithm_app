import '../Network/shared.dart';
import '../../modules/Login/data/model/login_response.dart';
import '../../modules/Clinics/data/model/clinics_model.dart';

class AuthService {
  static User? get currentUser => CacheHelper.getUser("user");

  static bool get isAdmin => currentUser?.userType?.toLowerCase() == 'admin';

  static Clinic? get userClinic => currentUser?.clinic;

  /// Whether the clinic selection UI (dropdown) should be visible.
  static bool get showClinicSelection => isAdmin;

  /// Returns the clinic that should be used for operations.
  /// If the user is an admin, it prioritizes a passed [selectedClinic],
  /// otherwise it returns the user's fixed clinic.
  static Clinic? getEffectiveClinic({Clinic? selectedClinic}) {
    if (isAdmin) {
      return selectedClinic;
    }
    return userClinic;
  }
}
