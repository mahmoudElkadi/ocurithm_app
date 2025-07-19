import 'package:flutter/material.dart';

import '../../../../../../../../core/utils/colors.dart';

class SuccessPopupDialog extends StatelessWidget {
  final String patientName;
  final String password;
  final VoidCallback? onSendMessage;
  final VoidCallback? onNavigateToPage;
  final VoidCallback? onClose;

  const SuccessPopupDialog({
    super.key,
    required this.patientName,
    required this.password,
    this.onSendMessage,
    this.onNavigateToPage,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close button in top right
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colorz.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colorz.primaryColor,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Success title
                  Text(
                    "Patient Added Successfully!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Patient info
                  Text(
                    "$patientName has been successfully registered in the system.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Column(
                    children: [
                      // Send Message Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onSendMessage?.call();
                          },
                          icon: const Icon(Icons.message, size: 20),
                          label: const Text(
                            "Send Welcome Message",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colorz.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Navigate Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onNavigateToPage?.call();
                          },
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          label: const Text(
                            "Make Appointment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colorz.primaryColor,
                            side: BorderSide(
                                color: Colorz.primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onClose?.call();
                          },
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text(
                            "Close",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
