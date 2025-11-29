import 'package:espoir_staff_app/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(AttendanceStarted());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            height: size.height * 0.35,
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state is AttendanceFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red),
                  );
                } else if (state is AttendanceSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Attendance Marked Successfully!'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                bool isWithinRange = false;
                double? distance;
                bool isLate = false;
                DateTime? punchInTime;
                bool isPunchOutEnabled = false;
                bool isAttendanceCompleted = false;
                int lateCount = 0;

                if (state is AttendanceLoaded) {
                  isWithinRange = state.isWithinRange;
                  distance = state.distance;
                  isLate = state.isLate;
                  punchInTime = state.punchInTime;
                  isPunchOutEnabled = state.isPunchOutEnabled;
                  isAttendanceCompleted = state.isAttendanceCompleted;
                  lateCount = state.lateCount;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Attendance",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (distance != null)
                              _buildInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Distance to Office',
                                value: '${distance.toStringAsFixed(2)} meters',
                                valueColor:
                                    isWithinRange ? Colors.green : Colors.red,
                              ),
                            if (state is AttendanceLoaded &&
                                state.userLocation != null &&
                                state.officeLocation != null) ...[
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                icon: Icons.person_pin_circle_outlined,
                                label: 'Your Location',
                                value:
                                    '${state.userLocation!['lat']!.toStringAsFixed(4)}, ${state.userLocation!['lng']!.toStringAsFixed(4)}',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                icon: Icons.business_outlined,
                                label: 'Office Location',
                                value:
                                    '${state.officeLocation!['lat']!.toStringAsFixed(4)}, ${state.officeLocation!['lng']!.toStringAsFixed(4)}',
                              ),
                            ],
                            if (!isWithinRange && distance != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'You are too far from the office to punch in.',
                                        style: TextStyle(
                                            color: Colors.red[700],
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Punch Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (punchInTime != null) ...[
                              Text(
                                'Punch In Time',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                TimeOfDay.fromDateTime(punchInTime)
                                    .format(context),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            _buildPunchButton(context,
                                isEnabled: isWithinRange,
                                punchInTime: punchInTime,
                                isPunchOutEnabled: isPunchOutEnabled,
                                isAttendanceCompleted: isAttendanceCompleted),
                            if (lateCount > 0) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: (lateCount > 3
                                          ? Colors.red
                                          : Colors.orange)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Late Count this Month: $lateCount/3',
                                  style: TextStyle(
                                    color: lateCount > 3
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            if (isLate) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLate
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.orangeAccent),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.access_time_filled,
                                        color: Colors.orange),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Warning: You are marking late attendance!',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Debug Button
                      TextButton.icon(
                        onPressed: () {
                          context
                              .read<AttendanceBloc>()
                              .add(SetCurrentLocationAsOffice());
                        },
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text(
                            'Set Current Location as Office (Debug)'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPunchButton(BuildContext context,
      {required bool isEnabled,
      required DateTime? punchInTime,
      required bool isPunchOutEnabled,
      required bool isAttendanceCompleted}) {
    if (isAttendanceCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 40),
            SizedBox(height: 8),
            Text(
              "Today's Attendance Successful",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (punchInTime != null) {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: isPunchOutEnabled
              ? () {
                  context.read<AttendanceBloc>().add(PunchOut());
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Punch-out cannot be done. Minimum 3.5 hours required.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor:
                isPunchOutEnabled ? const Color(0xFFE76F84) : Colors.grey,
            elevation: 0,
          ),
          child: const Text(
            'PUNCH OUT',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                context.read<AttendanceBloc>().add(PunchIn());
              }
            : null,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: isEnabled ? const Color(0xFF6C63FF) : Colors.grey,
          elevation: 0,
        ),
        child: const Text(
          'PUNCH IN',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
