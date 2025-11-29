import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final DateTime punchIn;
  final DateTime? punchOut;
  final bool isLate;
  final String? status;

  Attendance(
      {required this.id,
      required this.punchIn,
      this.punchOut,
      this.isLate = false,
      this.status});

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      punchIn: (data['punchIn'] as Timestamp).toDate(),
      punchOut: data.containsKey('punchOut')
          ? (data['punchOut'] as Timestamp).toDate()
          : null,
      isLate: data['isLate'] ?? false,
      status: data['status'],
    );
  }
}
