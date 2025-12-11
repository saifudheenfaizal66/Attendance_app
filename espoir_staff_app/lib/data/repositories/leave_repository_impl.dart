import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:espoir_staff_app/data/models/leave_model.dart';
import 'package:espoir_staff_app/domain/entities/leave.dart';
import 'package:espoir_staff_app/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final FirebaseFirestore _firestore;

  LeaveRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> applyLeave(Leave leave) async {
    final leaveModel = LeaveModel.fromEntity(leave);
    await _firestore.collection('leaves').add(leaveModel.toFirestore());
  }

  @override
  Stream<List<Leave>> getLeaves(String userId) {
    return _firestore
        .collection('leaves')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final leaves =
          snapshot.docs.map((doc) => LeaveModel.fromFirestore(doc)).toList();
      leaves.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
      return leaves;
    });
  }

  @override
  Future<void> cancelLeave(String leaveId) async {
    await _firestore.collection('leaves').doc(leaveId).delete();
  }

  @override
  Future<int> calculateLeaveDays(DateTime from, DateTime to) async {
    int totalDays = 0;
    DateTime current = from;

    // Fetch holidays from Firestore
    // Assuming 'holidays' collection has documents with a 'date' field (Timestamp)
    final holidaysSnapshot = await _firestore.collection('holidays').get();
    final holidays = holidaysSnapshot.docs.map((doc) {
      return (doc.data()['date'] as Timestamp).toDate();
    }).toList();

    while (current.isBefore(to) || current.isAtSameMomentAs(to)) {
      // 1. Exclude Sundays
      if (current.weekday == DateTime.sunday) {
        current = current.add(const Duration(days: 1));
        continue;
      }

      // 2. Exclude 2nd Saturdays
      if (current.weekday == DateTime.saturday) {
        int weekOfMonth = (current.day - 1) ~/ 7 + 1;
        if (weekOfMonth == 2) {
          current = current.add(const Duration(days: 1));
          continue;
        }
      }

      // 3. Exclude Holidays
      bool isHoliday = holidays.any((holiday) =>
          holiday.year == current.year &&
          holiday.month == current.month &&
          holiday.day == current.day);

      if (isHoliday) {
        current = current.add(const Duration(days: 1));
        continue;
      }

      totalDays++;
      current = current.add(const Duration(days: 1));
    }

    return totalDays;
  }

  @override
  Future<List<Leave>> getApprovedLeavesForMonth(
      String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await _firestore
        .collection('leaves')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Approved')
        .get();

    final allApprovedLeaves =
        snapshot.docs.map((doc) => LeaveModel.fromFirestore(doc)).toList();

    // Filter locally for month overlap
    // A leave counts for a month if any part of it falls within that month
    return allApprovedLeaves.where((leave) {
      // Check if leave date range overlaps with the month
      return leave.fromDate.isBefore(endOfMonth) &&
          leave.toDate.isAfter(startOfMonth);
    }).toList();
  }
}
