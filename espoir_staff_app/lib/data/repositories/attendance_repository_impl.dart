import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:espoir_staff_app/domain/repositories/attendance_repository.dart';
import 'package:espoir_staff_app/models/attendance.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> punchIn(String userId, {bool isLate = false}) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .add({
      'punchIn': FieldValue.serverTimestamp(),
      'isLate': isLate,
    });

    if (isLate) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      List<dynamic> lateDates = [];
      if (userDoc.exists && userDoc.data()!.containsKey('late_dates')) {
        lateDates = List.from(userDoc.data()!['late_dates']);
      }

      final now = DateTime.now();
      // Filter dates to keep only current month
      lateDates = lateDates.where((date) {
        final d = (date as Timestamp).toDate();
        return d.month == now.month && d.year == now.year;
      }).toList();

      lateDates.add(Timestamp.fromDate(now));

      await _firestore.collection('users').doc(userId).set({
        'late_dates': lateDates,
        'late_count':
            lateDates.length, // Keep for backward compatibility/easy read
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<Map<String, dynamic>> getOfficeConfig() async {
    final doc =
        await _firestore.collection('settings').doc('office_config').get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception('Office config not found');
    }
  }

  @override
  Future<void> setOfficeLocation(double lat, double lng, double radius) async {
    await _firestore.collection('settings').doc('office_config').set({
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
  }

  @override
  Future<void> punchOut(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('punchIn', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docId = doc.id;
      final punchInTime = (doc['punchIn'] as Timestamp).toDate();
      final now = DateTime.now();
      final duration = now.difference(punchInTime);

      String status = 'Half Day';
      if (duration.inHours >= 4) {
        status = 'Full Day';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(docId)
          .update({
        'punchOut': FieldValue.serverTimestamp(),
        'status': status,
      });
    }
  }

  @override
  Stream<List<Attendance>> getAttendanceHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('punchIn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<Attendance?> getLatestAttendance(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('punchIn', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Attendance.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  @override
  Future<int> getLateCount(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('late_count')) {
      return doc.data()!['late_count'] as int;
    }
    return 0;
  }

  @override
  Future<List<Attendance>> getWeeklyAttendance(String userId) async {
    final now = DateTime.now();
    // Calculate start of the week (Monday)
    // weekday: Mon=1, ..., Sun=7
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);

    // Calculate end of the week (Sunday end of day)
    final endOfWeek = startOfMonday.add(const Duration(days: 7));

    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .where('punchIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonday))
        .where('punchIn', isLessThan: Timestamp.fromDate(endOfWeek))
        .orderBy('punchIn', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => Attendance.fromFirestore(doc))
        .toList();
  }
}
