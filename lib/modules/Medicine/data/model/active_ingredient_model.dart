class ActiveIngredientsModel {
  ActiveIngredientsModel({
    required this.activeIngredients,
    this.total,
    this.totalPages,
    this.error,
  });

  List<ActiveIngredient> activeIngredients;
  num? total;
  num? totalPages;
  String? error;

  factory ActiveIngredientsModel.fromJson(Map<String, dynamic> json) {
    return ActiveIngredientsModel(
      activeIngredients: json["activeIngredients"] == null
          ? []
          : List<ActiveIngredient>.from(json["activeIngredients"]!
              .map((x) => ActiveIngredient.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "activeIngredients": activeIngredients.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "error": error,
      };
}

class ActiveIngredient {
  ActiveIngredient({
    this.name,
    this.id,
    this.error,
  });

  String? name;
  String? id;
  String? error;

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      name: json["name"],
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "error": error,
      };
}
