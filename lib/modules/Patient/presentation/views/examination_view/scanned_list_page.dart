import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/colors.dart';

class ScannedListPage extends StatelessWidget {
  final String patientId;
  const ScannedListPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Items"),
        centerTitle: true,
        backgroundColor: Colorz.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 60, color: Colorz.primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              "No scanned items yet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  } 
}
