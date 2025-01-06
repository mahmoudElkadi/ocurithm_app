import '../../../Login/data/model/login_response.dart';

class CapabilityModel {
  CapabilityModel({
    required this.capabilities,
  });

  final List<Capability> capabilities;

  factory CapabilityModel.fromJson(Map<String, dynamic> json) {
    return CapabilityModel(
      capabilities: json["capabilities"] == null ? [] : List<Capability>.from(json["capabilities"]!.map((x) => Capability.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "capabilities": capabilities.map((x) => x.toJson()).toList(),
      };
}
