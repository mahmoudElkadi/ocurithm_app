import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class PaymentMethodsModel {
  PaymentMethodsModel({
    this.paymentMethods,
    this.total,
    this.totalPages,
    this.error,
  });

  List<PaymentMethod>? paymentMethods;
  num? total;
  num? totalPages;
  String? error;

  factory PaymentMethodsModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsModel(
      paymentMethods: json["paymentMethods"] == null ? [] : List<PaymentMethod>.from(json["paymentMethods"]!.map((x) => PaymentMethod.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "paymentMethods": paymentMethods?.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class PaymentMethod {
  PaymentMethod({this.title, this.description, this.isActive, this.createdAt, this.updatedAt, this.id, this.error, this.clinic});

  String? title;
  String? description;
  Clinic? clinic;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      title: json["title"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      description: json["description"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {"title": title, "description": description, "clinic": clinic?.id};
}
