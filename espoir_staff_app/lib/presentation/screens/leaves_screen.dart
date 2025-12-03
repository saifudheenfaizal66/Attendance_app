import 'package:espoir_staff_app/domain/entities/leave.dart';
import 'package:espoir_staff_app/presentation/blocs/leave/leave_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/leave/leave_event.dart';
import 'package:espoir_staff_app/presentation/blocs/leave/leave_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<LeaveBloc>().add(LoadLeaves(userId));
    }
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
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocConsumer<LeaveBloc, LeaveState>(
                    listener: (context, state) {
                      if (state is LeaveOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      } else if (state is LeaveFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is LeaveLoading) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      } else if (state is LeaveLoaded) {
                        return Column(
                          children: [
                            _buildSummarySection(context, state.leaves),
                            const SizedBox(height: 20),
                            Expanded(
                              child: state.leaves.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      itemCount: state.leaves.length,
                                      itemBuilder: (context, index) {
                                        final leave = state.leaves[index];
                                        return _buildLeaveCard(context, leave);
                                      },
                                    ),
                            ),
                          ],
                        );
                      } else if (state is LeaveFailure) {
                        return Center(
                            child: Text('Error: ${state.error}',
                                style: const TextStyle(color: Colors.white)));
                      }
                      return const Center(
                          child: Text('Something went wrong.',
                              style: TextStyle(color: Colors.white)));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showApplyLeaveBottomSheet(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "My Leaves",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, List<Leave> leaves) {
    int total = leaves.length;
    int approved = leaves.where((l) => l.status == 'Approved').length;
    int pending = leaves.where((l) => l.status == 'Pending').length;
    int rejected = leaves.where((l) => l.status == 'Rejected').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  context, 'Total', total.toString(), Colors.blue)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatCard(
                  context, 'Approved', approved.toString(), Colors.green)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatCard(
                  context, 'Pending', pending.toString(), Colors.orange)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatCard(
                  context, 'Rejected', rejected.toString(), Colors.red)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 60, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'You have not applied for any leaves.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, Leave leave) {
    final statusInfo = _getStatusInfo(leave.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    leave.reason,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusInfo.icon, color: statusInfo.color, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        leave.status,
                        style: TextStyle(
                          color: statusInfo.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.date_range_outlined,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat.yMMMd().format(leave.fromDate)} - ${DateFormat.yMMMd().format(leave.toDate)}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${leave.totalDays} Days',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'Approved':
        return _StatusInfo(Colors.green, Icons.check_circle);
      case 'Pending':
        return _StatusInfo(Colors.orange, Icons.hourglass_bottom);
      case 'Rejected':
        return _StatusInfo(Colors.red, Icons.cancel);
      default:
        return _StatusInfo(Colors.grey, Icons.help_outline);
    }
  }

  void _showApplyLeaveBottomSheet(BuildContext context) {
    final reasonController = TextEditingController();
    DateTime? fromDate;
    DateTime? toDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apply for Leave',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                fromDate = date;
                                // Reset toDate if it's before fromDate
                                if (toDate != null &&
                                    toDate!.isBefore(fromDate!)) {
                                  toDate = null;
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(fromDate == null
                              ? 'From Date'
                              : DateFormat.yMMMd().format(fromDate!)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: fromDate ?? DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => toDate = date);
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(toDate == null
                              ? 'To Date'
                              : DateFormat.yMMMd().format(toDate!)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.isNotEmpty &&
                            fromDate != null &&
                            toDate != null) {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            context.read<LeaveBloc>().add(ApplyLeave(
                                  userId: userId,
                                  fromDate: fromDate!,
                                  toDate: toDate!,
                                  reason: reasonController.text,
                                ));
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Submit Application'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;

  _StatusInfo(this.color, this.icon);
}
