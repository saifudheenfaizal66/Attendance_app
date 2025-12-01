import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:espoir_staff_app/domain/entities/leave.dart';

class LeaveModel extends Leave {
  const LeaveModel({
    required super.id,
    required super.userId,
    required super.fromDate,
    required super.toDate,
    required super.reason,
    required super.status,
    required super.appliedOn,
    required super.totalDays,
  });

  factory LeaveModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LeaveModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fromDate: (data['fromDate'] as Timestamp).toDate(),
      toDate: (data['toDate'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'Pending',
      appliedOn: (data['appliedOn'] as Timestamp).toDate(),
      totalDays: data['totalDays'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'reason': reason,
      'status': status,
      'appliedOn': Timestamp.fromDate(appliedOn),
      'totalDays': totalDays,
    };
  }

  factory LeaveModel.fromEntity(Leave leave) {
    return LeaveModel(
      id: leave.id,
      userId: leave.userId,
      fromDate: leave.fromDate,
      toDate: leave.toDate,
      reason: leave.reason,
      status: leave.status,
      appliedOn: leave.appliedOn,
      totalDays: leave.totalDays,
    );
  }
}
