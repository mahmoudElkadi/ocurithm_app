import 'package:flutter/material.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: Text("Admin Home"), title: "Admin Home");
  }
}
