import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class ActiveIngredientModel {
    ActiveIngredientModel({
         this.success,
        required this.activeIngredients,
         this.total,
         this.totalPages,
    });

    final bool? success;
    final List<ActiveIngredient> activeIngredients;
    final num? total;
    final num? totalPages;

    factory ActiveIngredientModel.fromJson(Map<String, dynamic> json){ 
        return ActiveIngredientModel(
            success: json["success"],
            activeIngredients: json["activeIngredients"] == null ? [] : List<ActiveIngredient>.from(json["activeIngredients"]!.map((x) => ActiveIngredient.fromJson(x))),
            total: json["total"],
            totalPages: json["totalPages"],
        );
    }

    Map<String, dynamic> toJson() => {
        "success": success,
        "activeIngredients": activeIngredients.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
    };

}

class ActiveIngredient {
    ActiveIngredient({
         this.createdBy,
         this.updatedBy,
         this.deletedAt,
         this.deletedBy,
         this.clinic,
         this.parentId,
         this.name,
         this.concentration,
         this.isActive,
         this.createdAt,
         this.updatedAt,
         this.isActiveIngredient,
         this.isCommercialName,
         this.id,
         this.description,
    });

    final String? createdBy;
    final String? updatedBy;
    final dynamic deletedAt;
    final dynamic deletedBy;
    final Clinic? clinic;
    final dynamic parentId;
    final String? name;
    final dynamic concentration;
    final bool? isActive;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final bool? isActiveIngredient;
    final bool? isCommercialName;
    final String? id;
    final String? description;

    factory ActiveIngredient.fromJson(Map<String, dynamic> json){ 
        return ActiveIngredient(
            createdBy: json["createdBy"],
            updatedBy: json["updatedBy"],
            deletedAt: json["deletedAt"],
            deletedBy: json["deletedBy"],
            clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
            parentId: json["parentId"],
            name: json["name"],
            concentration: json["concentration"],
            isActive: json["isActive"],
            createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
            updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
            isActiveIngredient: json["isActiveIngredient"],
            isCommercialName: json["isCommercialName"],
            id: json["id"],
            description: json["description"],
        );
    }

    Map<String, dynamic> toJson() => {
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "deletedAt": deletedAt,
        "deletedBy": deletedBy,
        "clinic": clinic?.toJson(),
        "parentId": parentId,
        "name": name,
        "concentration": concentration,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isActiveIngredient": isActiveIngredient,
        "isCommercialName": isCommercialName,
        "id": id,
        "description": description,
    };

}


