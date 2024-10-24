class CreateReceptionistModel {
  String? data;
  String? error;

  CreateReceptionistModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    error = json['error'];
  }
}
