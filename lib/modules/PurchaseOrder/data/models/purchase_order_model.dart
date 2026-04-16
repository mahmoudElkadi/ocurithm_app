import 'package:ocurithm/modules/Product/data/models/product_model.dart';
import 'package:ocurithm/modules/Supplier/data/models/supplier_model.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class PurchaseOrderListModel {
  PurchaseOrderListModel({
    required this.purchaseOrders,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<PurchaseOrderHeader> purchaseOrders;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory PurchaseOrderListModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderListModel(
      purchaseOrders: json["purchaseOrders"] == null
          ? []
          : List<PurchaseOrderHeader>.from(
              json["purchaseOrders"]!.map((x) => PurchaseOrderHeader.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  PurchaseOrderListModel copyWith({
    List<PurchaseOrderHeader>? purchaseOrders,
    num? total,
    num? totalPages,
    bool? success,
  }) {
    return PurchaseOrderListModel(
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      success: success ?? this.success,
    );
  }
}

class PurchaseOrderHeader {
  PurchaseOrderHeader({
    this.id,
    this.poNumber,
    this.supplier,
    this.clinic,
    this.status,
    this.totalItems,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? poNumber;
  final Supplier? supplier;
  final Clinic? clinic;
  final String? status;
  final num? totalItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PurchaseOrderHeader.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderHeader(
      id: json["id"],
      poNumber: json["poNumber"],
      supplier: json["supplier"] == null ? null : Supplier.fromJson(json["supplier"]),
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      status: json["status"],
      totalItems: json["totalItems"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  PurchaseOrderHeader copyWith({
    String? id,
    String? poNumber,
    Supplier? supplier,
    Clinic? clinic,
    String? status,
    num? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderHeader(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplier: supplier ?? this.supplier,
      clinic: clinic ?? this.clinic,
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseOrderDetails {
  PurchaseOrderDetails({
    this.id,
    this.poNumber,
    this.supplier,
    this.clinic,
    this.status,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? poNumber;
  final Supplier? supplier;
  final Clinic? clinic;
  final String? status;
  final List<PurchaseOrderItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PurchaseOrderDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetails(
      id: json["id"],
      poNumber: json["poNumber"],
      supplier: json["supplier"] == null ? null : Supplier.fromJson(json["supplier"]),
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      status: json["status"],
      items: json["items"] == null
          ? []
          : List<PurchaseOrderItem>.from(
              json["items"]!.map((x) => PurchaseOrderItem.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  PurchaseOrderDetails copyWith({
    String? id,
    String? poNumber,
    Supplier? supplier,
    Clinic? clinic,
    String? status,
    List<PurchaseOrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderDetails(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplier: supplier ?? this.supplier,
      clinic: clinic ?? this.clinic,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseOrderItem {
  PurchaseOrderItem({
    this.product,
    this.quantity,
    this.purchasePrice,
    this.receivedQuantity,
    this.soldQuantity,
    this.remainingQuantity,
  });

  final Product? product;
  final num? quantity;
  final num? purchasePrice;
  final num? receivedQuantity;
  final num? soldQuantity;
  final num? remainingQuantity;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      product: json["product"] == null ? null : Product.fromJson(json["product"]),
      quantity: json["quantity"],
      purchasePrice: json["purchasePrice"],
      receivedQuantity: json["receivedQuantity"],
      soldQuantity: json["soldQuantity"],
      remainingQuantity: json["remainingQuantity"],
    );
  }

  PurchaseOrderItem copyWith({
    Product? product,
    num? quantity,
    num? purchasePrice,
    num? receivedQuantity,
    num? soldQuantity,
    num? remainingQuantity,
  }) {
    return PurchaseOrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
    );
  }
}

class CreatePurchaseOrderRequest {
  final String supplierId;
  final List<CreatePurchaseOrderItem> items;

  CreatePurchaseOrderRequest({required this.supplierId, required this.items});

  Map<String, dynamic> toJson() => {
        "supplierId": supplierId,
        "items": items.map((x) => x.toJson()).toList(),
      };
}

class CreatePurchaseOrderItem {
  final String productId;
  final num quantity;
  final num purchasePrice;

  CreatePurchaseOrderItem({
    required this.productId,
    required this.quantity,
    required this.purchasePrice,
  });

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "quantity": quantity,
        "purchasePrice": purchasePrice,
      };
}
