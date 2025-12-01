import 'package:equatable/equatable.dart';

class Leave extends Equatable {
  final String id;
  final String userId;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime appliedOn;
  final int totalDays;

  const Leave({
    required this.id,
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.appliedOn,
    required this.totalDays,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        fromDate,
        toDate,
        reason,
        status,
        appliedOn,
        totalDays,
      ];
}
