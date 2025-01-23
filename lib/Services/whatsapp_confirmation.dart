import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/colors.dart';

class WhatsAppConfirmation {
  Future<void> sendWhatsAppMessage(String phone, String message) async {
    // Ensure the phone number is formatted correctly for Egypt
    final formattedPhone = "20${phone.replaceFirst(RegExp(r'^0'), '')}";

    final whatsappUrl = Uri.parse("whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}");

    // Print URL for debugging purposes
    print("WhatsApp URL: $whatsappUrl");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        Get.snackbar(
          "WhatsApp not installed",
          "Please install WhatsApp to send messages.",
          colorText: Colorz.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to launch WhatsApp.",
        colorText: Colorz.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error),
      );
    }
  }
}
