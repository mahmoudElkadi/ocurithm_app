import '../Network/shared.dart';

class CapabilityServices {
  static bool hasCapability(String capability){
    if(CacheHelper.getStringList(key: "capabilities").contains(capability)||CacheHelper.getStringList(key: "capabilities").contains("manageCapability")){
      return true;
    }else{
      return false;
    }
  }
}