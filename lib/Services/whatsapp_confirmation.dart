import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/colors.dart';

class WhatsAppConfirmation {
  Future<void> sendWhatsAppMessage(String phone, String message) async {
    // Ensure the phone number is formatted correctly for Egypt
    final formattedPhone = phone.replaceFirst(RegExp(r'^0'), '');

    // Create both regular and business WhatsApp URLs
    final whatsappUrl = Uri.parse(
        "whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}");
    final whatsappUrlAlternative = Uri.parse(
        "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");

    try {
      // Try launching with whatsapp:// scheme first
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
      // If that fails, try the https://wa.me link
      else if (await canLaunchUrl(whatsappUrlAlternative)) {
        await launchUrl(whatsappUrlAlternative,
            mode: LaunchMode.externalApplication);
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
      print("Error launching WhatsApp: $e");
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
