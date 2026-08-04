import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import '../../../Payment Methods/data/model/payment_method_model.dart';

enum OrderStatus { completed, cancelled }

class OrderModel {
  final List<Order> orders;
  final num? total;
  final num? totalPages;
  final bool? success;

  OrderModel({
    required this.orders,
    this.total,
    this.totalPages,
    this.success,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orders: json["orders"] == null
          ? []
          : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "orders": orders.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };
}

class Order {
  final String? id;
  final String? orderNumber;
  final Clinic? clinic;
  final Branch? branch;
  final Doctor? doctor;
  final PaymentMethod? paymentMethod;
  final List<OrderItem> items;
  final num? totalPrice;
  final OrderStatus? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.orderNumber,
    this.clinic,
    this.branch,
    this.doctor,
    this.paymentMethod,
    required this.items,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderStatus? parseStatus(String? status) {
      if (status == "completed") return OrderStatus.completed;
      if (status == "cancelled") return OrderStatus.cancelled;
      return null;
    }

    // The API returns paymentMethod either populated or as a bare id string,
    // depending on the endpoint — web handles both, so mobile must too.
    PaymentMethod? parsePaymentMethod(dynamic value) {
      if (value == null) return null;
      if (value is String) return PaymentMethod(id: value);
      if (value is Map<String, dynamic>) return PaymentMethod.fromJson(value);
      return null;
    }

    return Order(
      id: json["id"],
      orderNumber: json["orderNumber"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
      paymentMethod: parsePaymentMethod(json["paymentMethod"]),
      items: json["items"] == null
          ? []
          : List<OrderItem>.from(
              json["items"]!.map((x) => OrderItem.fromJson(x))),
      totalPrice: json["totalPrice"],
      status: parseStatus(json["status"]),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "orderNumber": orderNumber,
        "clinic": clinic?.id,
        "branch": branch?.id,
        "doctor": doctor?.id,
        "paymentMethod": paymentMethod?.id,
        "items": items.map((x) => x.toJson()).toList(),
        "totalPrice": totalPrice,
        "status": status?.name,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };

  Order copyWith({
    String? id,
    String? orderNumber,
    Clinic? clinic,
    Branch? branch,
    Doctor? doctor,
    List<OrderItem>? items,
    num? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      clinic: clinic ?? this.clinic,
      branch: branch ?? this.branch,
      doctor: doctor ?? this.doctor,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String? productId;
  final String? productName;
  final String? productSku;
  final num? productPrice;
  final num? quantity;

  OrderItem({
    this.productId,
    this.productName,
    this.productSku,
    this.productPrice,
    this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json["productId"],
      productName: json["productName"],
      productSku: json["productSku"],
      productPrice: json["productPrice"],
      quantity: json["quantity"],
    );
  }

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "productSku": productSku,
        "productPrice": productPrice,
        "quantity": quantity,
      };
}
