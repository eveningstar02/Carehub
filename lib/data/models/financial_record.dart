import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/json_helpers.dart';

class FinancialRecord {
  FinancialRecord({
    this.id,
    required this.recordType,
    required this.amount,
    this.description,
    this.receiptUrl,
    required this.recordDate,
    this.balanceAfter,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String? id;
  FinancialType recordType;
  double amount;
  String? description;
  String? receiptUrl;
  DateTime recordDate;
  double? balanceAfter;
  DateTime updatedAt;

  factory FinancialRecord.fromJson(Map<String, dynamic> row) {
    return FinancialRecord(
      id: row['id'] as String?,
      recordType: enumFromName(
        FinancialType.values,
        row['record_type'] as String?,
        FinancialType.expense,
      ),
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      description: row['description'] as String?,
      receiptUrl: row['receipt_url'] as String?,
      recordDate: parseJsonDate(row['record_date']) ?? DateTime.now(),
      balanceAfter: (row['balance_after'] as num?)?.toDouble(),
      updatedAt: parseJsonDate(row['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId && id != null) 'id': id,
        'record_type': recordType.name,
        'amount': amount,
        'description': description,
        'receipt_url': receiptUrl,
        'record_date': recordDate.toIso8601String(),
        'balance_after': balanceAfter,
        'updated_at': updatedAt.toIso8601String(),
      };
}
