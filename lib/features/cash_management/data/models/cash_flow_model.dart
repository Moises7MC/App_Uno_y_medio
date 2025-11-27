import '../../domain/entities/cash_flow.dart';

class CashFlowModel extends CashFlowEntity {
  CashFlowModel({
    required super.id,
    required super.initialBalance,
    required super.openingTime,
    super.finalBalance = 0.0,
    super.closingTime,
    super.totalSales = 0.0,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      id: json['id'],
      initialBalance: (json['initialBalance'] as num).toDouble(),
      openingTime: DateTime.parse(json['openingTime']),
      finalBalance: (json['finalBalance'] as num?)?.toDouble() ?? 0.0,
      closingTime: json['closingTime'] != null
          ? DateTime.parse(json['closingTime'])
          : null,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'initialBalance': initialBalance,
      'openingTime': openingTime.toIso8601String(),
      'finalBalance': finalBalance,
      'closingTime': closingTime?.toIso8601String(),
      'totalSales': totalSales,
    };
  }

  factory CashFlowModel.fromEntity(CashFlowEntity entity) {
    return CashFlowModel(
      id: entity.id,
      initialBalance: entity.initialBalance,
      openingTime: entity.openingTime,
      finalBalance: entity.finalBalance,
      closingTime: entity.closingTime,
      totalSales: entity.totalSales,
    );
  }

  CashFlowModel copyWith({
    String? id,
    double? initialBalance,
    DateTime? openingTime,
    double? finalBalance,
    DateTime? closingTime,
    double? totalSales,
  }) {
    return CashFlowModel(
      id: id ?? this.id,
      initialBalance: initialBalance ?? this.initialBalance,
      openingTime: openingTime ?? this.openingTime,
      finalBalance: finalBalance ?? this.finalBalance,
      closingTime: closingTime ?? this.closingTime,
      totalSales: totalSales ?? this.totalSales,
    );
  }
}