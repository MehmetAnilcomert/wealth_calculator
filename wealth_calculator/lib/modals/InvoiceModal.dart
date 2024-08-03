import 'package:flutter/material.dart';

enum ImportanceLevel {
  highPriority,
  mediumPriority,
  lowPriority,
}

class InvoiceModal {
  String? name;
  int? amount;
  String? explanation;
  DateTime? dueDate;
  DateTime? startDate;
  ImportanceLevel? priority;
  bool? isPaid;

  InvoiceModal({
    required this.name,
    required this.amount,
    this.explanation,
    required this.dueDate,
    this.startDate,
    required this.priority,
    this.isPaid,
  });

  // fromJson factory constructor
  factory InvoiceModal.fromJson(Map<String, dynamic> json) {
    return InvoiceModal(
      name: json['name'],
      amount: json['amount'],
      explanation: json['explanation'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      priority: json['priority'] != null
          ? ImportanceLevel.values.firstWhere(
              (e) => e.toString() == 'ImportanceLevel.${json['priority']}')
          : null,
      isPaid: json['isPaid'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'explanation': explanation,
      'dueDate': dueDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'priority': priority?.toString().split('.').last,
      'isPaid': isPaid,
    };
  }
}
