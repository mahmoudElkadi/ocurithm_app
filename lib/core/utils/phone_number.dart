import 'dart:developer';

import 'package:flutter_intl_phone_field/phone_number.dart';

class PhoneNumberService {
  static Map<String, String> parsePhone(String? fullPhoneNumber) {
    if (fullPhoneNumber == null || fullPhoneNumber.isEmpty) {
      return {'countryCode': 'EG', 'phoneNumber': ''};
    }

    try {
      final phoneNumber = PhoneNumber.fromCompleteNumber(completeNumber: fullPhoneNumber);
      return {
        'countryCode': phoneNumber.countryISOCode,
        'phoneNumber': phoneNumber.number, // National significant number
      };
    } catch (e) {
      // Fallback to manual parsing if package fails
      log(e.toString());
      return {'countryCode': 'EG', 'phoneNumber': ''};
    }
  }
}
