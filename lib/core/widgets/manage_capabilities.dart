import 'package:flutter/material.dart';

import '../Network/shared.dart';

class ManageCapabilities extends StatelessWidget {
  const ManageCapabilities({super.key, required this.capability, required this.child});
  final String capability;
  final Widget child;



  @override
  Widget build(BuildContext context) {
   if(CacheHelper.getStringList(key: "capabilities").contains(capability) || CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities") ){
     return child;
   }else{
     return const SizedBox.shrink();
   }
  }
}
